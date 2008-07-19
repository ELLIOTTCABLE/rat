module Kernel
  def forever
    begin
      while true
        yield
      end
    rescue Interrupt
      exit
    end
  end
end