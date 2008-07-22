# This is an example file, to display how a protocol can be created. This
# psuedo-protocol, however, only sends messages to 'say', so they will be
# spoken out loud.

($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', 'lib' ))).uniq!
require 'rat'

class Rat::Protocol::Say < Rat::Protocol::Base
  def << message
    super message
    `say "#{message.to_s}"`
  end
end

Rat.start