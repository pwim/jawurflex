require 'kconv'
require 'rubygems'
require 'hpricot'
require 'jawurflex/handset'

class Jawurflex::Handset::SoftbankHandset < Jawurflex::Handset
  NAME = 0
  GENERATION = 2
  BROWSER_USER_AGENT = 4
  X_JPHONE_NAME = 9
  X_JPHONE_DISPLAY = 10
  X_JPHONE_COLOR = 11
  FLASH = 18
  BROWSER_DISPLAY_AREA = 23

  def self.parse_handsets
    device_name_to_handset = {}
    parse_user_agent_data(device_name_to_handset)
    parse_header_data(device_name_to_handset)
    parse_service_data(device_name_to_handset)
    parse_display_data(device_name_to_handset)
    # Softbank has some old devices with multiple versions where the user agent
    # is the same, i.e., 812SH s2 and 812SH s.  In this case, choose the device
    # that has the name that is highest in lexographical order
    user_agents_to_handsets = Hash.new {|h,k| h[k] = []}
    device_name_to_handset.values.each do |h|
      user_agents_to_handsets[h.user_agent] << h
    end
    return user_agents_to_handsets.map do |k,v|
      v.max {|a,b| a.name <=> b.name }
    end
  end

  def self.parse_user_agent_data(device_name_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/softbank/terminal/?lup=y&cat=ua").read)
    Hpricot(s).search("table/tr[@bgcolor='#FFFFFF']").each do |r|
      columns = r.search("td")
      if columns.first.attributes["rowspan"] == "5"
        model_name, user_agent = columns.map {|c| c.innerText}
        h = new(:name => strip_name(model_name))
        h.user_agent = user_agent =~ /(.+)\[\/Serial\].*/ ? $1 : user_agent
        h.markup << (h.user_agent =~ /J-PHONE/ ? 'mml' : 'softbank_xhtml_mp')
        device_name_to_handset[h.name] = h
      end
    end
  end

  def self.parse_header_data(device_name_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/softbank/terminal/?lup=y&cat=http").read)
    Hpricot(s).search("table/tr[@bgcolor='#FFFFFF']").each do |r|
      columns = r.search("td")
      if columns.size == 8
        model_name, jphone_name, jphone_display, jphone_colors, others = columns.map {|c| c.innerText }
        h = device_name_to_handset[strip_name(model_name)]
        h.physical_width, h.physical_height = jphone_display.split("*").map {|s| s.to_i}
        h.colors = jphone_colors.match(/\d+/)[0].to_i
        h.device_id = jphone_name.strip
      end
    end
  end

  def self.parse_service_data(device_name_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/softbank/terminal/?lup=y&cat=service").read)
    Hpricot(s).search("table/tr[@bgcolor='#FFFFFF']").each do |r|
      columns = r.search("td")
      h = device_name_to_handset[strip_name(columns[0].innerText)]
      h.flash_lite = columns[3].innerText =~ /Flash Lite.*(\d\.\d)/ ? $1 : nil
    end
  end

  def self.parse_display_data(device_name_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/softbank/terminal/?lup=y&cat=display").read)
    Hpricot(s).search("table/tr[@bgcolor='#FFFFFF']").each do |r|
      columns = r.search("td")
      h = device_name_to_handset[strip_name(columns[0].innerText)]
      h.browser_width, h.browser_height = columns[1].innerText.
        match(/(\d+) x (\d+)/)[1,2].map {|s| s.to_i }
    end
  end

  def self.strip_name(s)
    s.match(/[^\r]*/)[0]
  end

  def brand_name
    "SoftBank"
  end

end

