require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'

puts 'Starting...'
@client = Jabber::Client.new(Jabber::JID.new('elliottcable@gmail.com/rat'))
puts 'Connecting...'
@client.connect.auth('90dffbdb')
@client.send Jabber::Presence.new.set_type(:available)

puts 'Creating subscription callback...'
@roster = Jabber::Roster::Helper.new(@client)
@roster.add_subscription_request_callback do |_, presence|
  @roster.accept_subscription presence.from
  puts "#{presence.from} requested friendship! Accepted, messaging..."
  @client.send Jabber::Message.new(presence.from, "Thanks for the presence subscription!").set_type(:normal).set_id('1').set_subject("WTF is an XMPP subject")
end

puts 'Creating message callback...'
@client.add_message_callback do |message|
  @client.send Jabber::Message.new(message.from, "You sent: #{message.body}").set_type(:normal).set_id('1').set_subject("WTF is an XMPP subject")
  puts "Message from #{message.from}: #{message.body}"
end

puts 'Woot! Staying logged on, ^C to quit.'
begin
  while true; end
rescue Interrupt
  exit
end