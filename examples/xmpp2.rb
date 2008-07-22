require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'

@@XMPP = Jabber::Client.new(Jabber::JID.new('elliottcable@gmail.com/rat'))
@@XMPP.connect.auth('secret')
@@XMPP.send Jabber::Presence.new.set_type(:available).set_priority(50)

@@XMPP.add_message_callback do |message|
  `say "message received"`
end

while true
  
end