require "jawurflex"
class Jawurflex::Handset 
  attr_accessor :device_id, :user_agent, :display_width, :display_height,
    :browser_width, :browser_height, :flash_lite, :brand_name, :markup,
    :xhtml_table_support, :name, :colors

  def initialize(args={})
    args.each {|k,v| send("#{k}=", v)}
    @markup ||= []
  end
end

