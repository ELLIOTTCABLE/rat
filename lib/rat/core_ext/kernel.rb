module Kernel
  def forever &block
    __forever__(&block ||= lambda {})
  end
  
  def __forever__
    begin
      while true
        yield
      end
    rescue Interrupt
      exit
    end
  end
end