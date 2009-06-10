require 'rubygems'
require 'kconv'
require 'hpricot'
require 'jawurflex/handset'

class Jawurflex::Handset::DocomoHandset < Jawurflex::Handset
  def self.parse_handsets
    device_id_to_handset = {} 
    parse_user_agent_data(device_id_to_handset)
    parse_spec_data(device_id_to_handset)
    parse_screen_data(device_id_to_handset)
    device_id_to_handset.values
  end

  def self.parse_user_agent_data(device_id_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/docomo/useragent/index.html").read)
    Hpricot(s).search("table[@class='layout cellpt01 full']/tr").map do |r|
      columns = r.search("td").
        reject {|c| c.attributes["class"] =~ /acenter/}.
        map {|c| c.at("span")}.
        compact.
        map {|c| c.innerHTML }
      if (1..2).any?{|i| columns[i] =~ %r{(DoCoMo/[12].0[/ ]\w+)}}
        user_agent = $1
        device_id = strip_device_id(columns[0])
        device_id_to_handset[device_id] =
          new(:device_id => device_id,
              :user_agent => user_agent,
              :name => device_id)
      end
    end
  end

  def self.strip_device_id(device_id)
    device_id.match(/[\w-]+/)[0]
  end

  def self.parse_spec_data(device_id_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/docomo/imode_spec.txt").read)
    words = s.split(/\s+/)
    device_id_to_handset.each do |device_id, h|
      index = words.index(device_id)
      index ||= words.index(words.find {|s| s =~ /#{device_id}/ })
      raise "Device #{device_id} not found" unless index
      offset = 1
      while words[index+offset] !~ /\d\.\d/
        offset += 1
      end
      browser_version, html_version, xhtml_version, flash_version =
        [0,1,2,5].map {|i| words[index+offset+i]}
      if browser_version == "1.0"
        h.markup << "imode_html_#{html_version.tr('.','_')}"
        h.markup.unshift("imode_xhtml_#{xhtml_version.tr('.','_')}") if xhtml_version.to_f > 0
      else
        h.markup << "imode_browser_2_0_xhtml"
      end
      h.xhtml_table_support = true if xhtml_version.to_f >= 2
      h.flash_lite = flash_version if flash_version.to_f > 0
    end
  end

  def self.parse_screen_data(device_id_to_handset)
    s = Kconv.toutf8(open("#{Jawurflex.data_directory}/docomo/screen_area/index.html").read)
    Hpricot(s).search("table[@class='layout cellpt01 full']/tr[@class='acenter']").map do |r|
      columns = r.search("td").
        map {|c| c.children.first.innerHTML }
      device_id = strip_device_id(columns[0])
      h = device_id_to_handset[device_id]
      unless h
        columns.shift
        device_id = strip_device_id(columns[0])
        h = device_id_to_handset[device_id]
      end

      raise "Device #{device_id} not found" unless h

      columns.shift if h.markup.first == "imode_browser_2_0_xhtml"

      if columns[3] =~ /(\d+)\303\227(\d+)/
        h.browser_width, h.browser_height = $1.to_i, $2.to_i
      else
        raise "Dimensions not found for #{device_id}"
      end

      if columns[4] =~ /(\d+)\303\227(\d+)/
        h.display_width, h.display_height = $1.to_i, $2.to_i
      else
        h.display_width, h.display_height = h.browser_width, h.browser_height
      end

      h.colors = columns[5].match(/\d+/)[0].to_i
    end
  end

  def brand_name
    "DoCoMo"
  end
end
