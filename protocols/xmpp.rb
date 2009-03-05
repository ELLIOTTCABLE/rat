require 'xmpp4r'
require 'xmpp4r/roster'

# Jabber::logger = Logger.new(STDERR)
Jabber::logger = Logger.new('logs/jabber.stream.log')

Jabber::logger.level = Logger::DEBUG
Jabber::logger.datetime_format = "%Y-%m-%d|%H:%M:%S"
Jabber::debug = true

class Rat::Protocol::XMPP < Rat::Protocol::Base
  def self.initialize
    super
    @@XMPP = Jabber::Client.new(Jabber::JID.new('elliottcable.testing@gmail.com/rat'))
    @@XMPP.connect.auth('sekretlol')
    @@XMPP.send Jabber::Presence.new.set_type(:available).set_priority(123)
  end
  
  def self.terminate
    @@XMPP.close
    super
  end
  
  def initialize window, target
    super window, target
    
    @@XMPP.add_message_callback do |message|
      if "#{message.from.node}@#{message.from.domain}" =~ /#{target}/
        @window << "#{target} > #{message.body}"
      end
    end
  end
  
  def << message
    @@XMPP.send Jabber::Message.new(
      @target,
      message
    ).set_type(:normal).set_id('1')
    super message
  end
end
