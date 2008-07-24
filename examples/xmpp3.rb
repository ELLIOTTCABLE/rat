require 'ncurses'
require 'xmpp4r'

# Initialize Ncurses
Ncurses.initscr
Ncurses.cbreak
#Ncurses.noecho
Ncurses.start_color if Ncurses.has_colors?
Ncurses.refresh

# Initialize window
@window = Ncurses.stdscr
@window.keypad = true
@window.refresh
@window.printw("%s", "Ncurses initialized")
at_exit { @window.delwin ; Ncurses.endwin }

# Logging
Jabber::logger = Logger.new(STDERR)
Jabber::logger.level = Logger::DEBUG
Jabber::logger.datetime_format = "%Y-%m-%d|%H:%M:%S"
Jabber::debug = true

# Protocol init
@@XMPP = Jabber::Client.new(Jabber::JID.new('elliottcable.testing@gmail.com/rat'))
@@XMPP.connect.auth('secret')
@@XMPP.send Jabber::Presence.new.set_type(:available).set_priority(50)

@@XMPP.add_message_callback do |message|
  `say "message received #{message.body}"`
  Rat::Window.active.puts message.body
end

loop do
  
end