module Kernel
  def forever &block
    block ||= lambda {}
    __forever__(&block)
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