require 'xmpp4r'
require 'xmpp4r/roster'

# Jabber::logger = Logger.new(STDERR)
Jabber::logger = Logger.new('jabberlog.txt')
Jabber::logger.level = Logger::DEBUG
Jabber::logger.datetime_format = "%Y-%m-%d|%H:%M:%S"
Jabber::debug = true

class Rat::Protocol::XMPP < Rat::Protocol::Base
  def self.initialize
    super
    `say "protocol initialized"`
    @@XMPP = Jabber::Client.new(Jabber::JID.new('elliottcable.testing@gmail.com/rat'))
    @@XMPP.connect.auth('secret')
    @@XMPP.send Jabber::Presence.new.set_type(:available).set_priority(50)
    
    @@XMPP.add_message_callback do |message|
      `say "message received #{message.body}"`
      Rat::Window.active.puts message.body
    end
  end
  
  def self.terminate
    `say "protocol terminating"`
    @@XMPP.close
    super
  end
  
  def initialize window, target
    `say "protocol instance initialized"`
    super window, target
    
    # @@XMPP.add_message_callback do |message|
    #   `say "message received"`
    #   # if message.from =~ /#{target}/
    #     @window << "#{message.from} > #{message.body}"
    #   # end
    # end
    
    $IGNORE_INPUT = true
  end
  
  def << message
    `say "sending message"`
    @@XMPP.send Jabber::Message.new(
      @target,
      message
    ).set_type(:normal).set_id('1')
    super message
  end
end