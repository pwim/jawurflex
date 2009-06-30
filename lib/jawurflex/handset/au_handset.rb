require 'rubygems'
require 'kconv'
require 'hpricot'
require 'jawurflex/handset'

class Jawurflex::Handset::AuHandset < Jawurflex::Handset
  def self.parse_handsets
    name_to_device_id = {}
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/au/4_4.html").read)
    Hpricot(s).search("table/tr[@bgcolor='#ffffff']").each do |r|
      columns = r.search("td/div").map {|c| c.innerText}
      (0..2).each do |i|
        name, device_id = (columns[i*2,2] || []).map {|s| s.strip}
        name_to_device_id[name] = device_id
      end
    end

    # Some devices are listed multiple times because the device name is
    # different for the same device id
    device_id_to_handset = {}
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/au/ezkishu.html").read)
    Hpricot(s).search("table[@width='892']/tr[@bgcolor='#ffffff']").each do |r|
      columns = r.search("td/div").map {|c| c.innerText}
      h = new(:name => columns[0])
      h.device_id = name_to_device_id[h.name]
      raise "No matching device_id for #{h.name}" unless h.device_id
      h.user_agent = "KDDI-#{h.device_id}"
      h.display_width, h.display_height = columns[5].split("\303\227").map {|s| s.to_i}
      h.browser_width, h.browser_height = columns[4].split("\303\227").map {|s| s.to_i}
      h.markup << "au_xhtml_mp"
      h.flash_lite = case columns[11]
      when "\342\227\217"
        "2.0"
      when "\342\227\216","\342\227\213"
        "1.1"
      when "\342\210\222"
      end
      h.colors = parse_colors(columns[2])
      device_id_to_handset[h.device_id] ||= h
    end
    device_id_to_handset.values
  end

  def self.parse_colors(s)
    # Sometimes kddi decides to use kanji in the number of colors.
    if m = s.match(/(\d+)\344\270\207((\d+)\345\215\203)?/)
      m[1].to_i * 10_000 + m[3].to_i * 1_000
    else
      s.sub(/,/, '').match(/\d+/)[0].to_i
    end
  end

  def brand_name
    "kddi"
  end

end
