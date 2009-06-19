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
    return device_name_to_handset.values
    csv = FasterCSV.open("#{Jawurflex.data_directory}/softbank/terminal/index.html")
    headers = csv.shift
    data = csv.map do |r|
      h = new(:name => r[NAME].match(/[^\r]*/)[0], 
              :device_id => r[X_JPHONE_NAME].strip)
      h.display_width, h.display_height = r[X_JPHONE_DISPLAY].
        split("*").map {|s| s.to_i}
      h.browser_width, h.browser_height = r[BROWSER_DISPLAY_AREA].
        match(/(\d+) x (\d+)/)[1,2].map {|s| s.to_i }
      h.markup << (r[GENERATION] == "3GC" ? 'softbank_xhtml_mp' : "mml")
      h.flash_lite = r[FLASH] =~ /Flash Lite\[TM\](\d\.\d)/ ? $1 : nil
      h.colors = r[X_JPHONE_COLOR].match(/\d+/)[0].to_i
      h
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
        device_name_to_handset[h.name] = h
      end
    end
  end

  def self.strip_name(s)
    s.match(/[^\r]*/)[0]
  end

  def brand_name
    "SoftBank"
  end
  
end

