require 'DRb_serve'

# Load this file once and them open a irb session. Try loading the module, you
# will be using DRb to connect to the server

module Test
  def self.a
    @counter ||= 0
    puts @counter += 1
    @counter
  end

  extend DRbServe
  serve :a
  hook
end

if __FILE__ == $0
  Test.start_server
end


