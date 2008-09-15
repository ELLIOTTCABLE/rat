require 'rubygems'
require 'spec'

module NcursesMock
  @@window_mock = nil
  # Sets the mock object that will be used as newly created 'windows' - allows
  # us to test what said new window "should receive" and whatnot during the
  # initialization process.
  def self.window_mock= mock
    @@window_mock = mock
  end
  def self.window_mock
    @@window_mock || Spec::Mocks::Mock.new('a window', :null_object => true)
  end
  
  def is_mock?
    true
  end
  
  def COLS; 80; end
  def LINES; 40; end
  
  def newwin *args
    return NcursesMock.window_mock
  end
end

module Ncurses
  extend NcursesMock
end