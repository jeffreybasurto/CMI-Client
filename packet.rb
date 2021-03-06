require 'yaml'
# a valid packet is formed with
class Packet
  # These are the expected types per each packet type.
  # packet is a fail if these packets do not exist.
  @expected = YAML.load_file("packet_config.yml")

  class << self; attr_accessor :expected; end

  def initialize data
    if data.is_a? String
      @data = YAML::load(data) rescue nil
    else
      @data = data
    end
  end

  # login as a certain mud.
  def self.login name, pw="none"
    Packet.new({"type"=>"login", "mud"=>name, "password"=>"none"})
  end

  def self.error txt
    Packet.new({"type"=>"error", "text"=>txt, "from"=>"local"})
  end

  def self.chat txt
    Packet.new({"type"=>"chat", "sender"=>"Default", "channel"=>"intermud", "text"=>txt})
  end

  # is this packet valid?
  def is_invalid?
    case @data
      when Hash
        type = @data["type"]
        return Packet.error("Packet type not included.") if type == nil
        Packet.expected[type].each do |expected|
          return Packet.error("Expected data of type #{expected} was not included.") if !@data[expected]
        end
        return false
    end
    return Packet.error "Bad data type for packet." # return false on anything else.
  end
  # do whatever this packet is designed to do right now.
  def execute
    case @data["type"]
      when "chat"
        puts @data["sender"] + " #{@data["channel"]}s, '" + @data["text"] + "'"
      when "error"
        puts "ERROR: " + @data["text"]
      when "notify"
        puts "Notify: #{@data["event"]}: #{@data["text"]}"
    end
  end
  def to_s
    @data.to_yaml
  end
end

