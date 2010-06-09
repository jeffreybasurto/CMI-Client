require 'eventmachine'

module Rclient
  def post_init; $client = self;  end
 
  def receive_data data
    puts data 
  end
 
  def unbind 
    puts "Connection closed."
    EventMachine::stop_event_loop
  end
end
 
# Autonomous thread
receive_thread = Thread.new do
  loop do 
    next if (s = gets.strip).empty?
    $client.send_data s + "\n"
  end 
end
 
EventMachine::run { EventMachine::connect "localhost", 5000, Rclient }
 
