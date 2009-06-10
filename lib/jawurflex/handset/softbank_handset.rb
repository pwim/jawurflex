require 'kconv'
require 'rubygems'
require 'fastercsv'
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
    csv = FasterCSV.open("#{Jawurflex.data_directory}/softbank/softbank.csv")
    headers = csv.shift
    data = csv.map do |r|
      h = new(:name => r[NAME].match(/[^\r]*/)[0], 
              :device_id => r[X_JPHONE_NAME].strip)
      m = r[BROWSER_USER_AGENT].match(/(.+)\[\/Serial\].*/)
      h.user_agent = m ? m[1] : r[BROWSER_USER_AGENT]
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

  def brand_name
    "SoftBank"
  end
end

