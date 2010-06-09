require 'eventmachine'
load 'packet.rb'

module Rclient
  def post_init
    $client = self

    send_data Packet.login("CoralMud")
  end
 
  def receive_data data
    # TODO need to make some way to capture and ensure a full packet is being sent.
    # Probably a delimiter but maybe just using the first 4 bytes for string length each time.
    packet = Packet.new(data)

    error = packet.is_invalid?
    # if there was an error then let's act upon it.
    if error
      error.execute
      return
    end

    # it's valid, so let's execute it.
    packet.execute
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
    $client.send_data Packet.chat(s).to_s + "\n"
  end 
end
 
EventMachine::run { EventMachine::connect "localhost", 5000, Rclient }
 
