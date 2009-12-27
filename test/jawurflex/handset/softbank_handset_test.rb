$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..', '..',  'lib')
require "test/unit"
require "jawurflex/handset/softbank_handset"

class SoftbankHandsetTest < Test::Unit::TestCase
  def test_parse_handsets
    handsets = Jawurflex::Handset::SoftbankHandset.parse_handsets
    handset = handsets.find {|h| h.device_id == "831SH" }
    assert_equal 400, handset.physical_height
    assert_equal 240, handset.physical_width
    assert_equal [ "softbank_xhtml_mp" ], handset.markup
    assert_equal "3.0", handset.flash_lite
    assert_equal 350, handset.browser_height
    assert_equal 240, handset.browser_width
    assert_equal "SoftBank/1.0/831SH/SHJ001", handset.user_agent
    assert_equal 262144, handset.colors

    handset = handsets.find {|h| h.device_id == "V703N" }
    assert_equal "Vodafone/1.0/V703N/NJ001", handset.user_agent

    handset = handsets.find {|h| h.device_id == "V702sMO" }
    assert_equal "MOT-C980/80.2F.2E. MIB/2.2.1 Profile/MIDP-2.0 Configuration/CLDC-1.1", handset.user_agent

    handset = handsets.find {|h| h.device_id == "821N"}
    assert_equal "821N", handset.name

    handset = handsets.find {|h| h.device_id == "J-DN02" }
    assert_equal 4, handset.colors
    assert_equal [ "mml" ], handset.markup

    handset = handsets.find {|h| h.device_id == "J-PE03B" }
    assert_equal "J-PE03\342\205\241", handset.name

    handset = handsets.find {|h| h.device_id == "812SHs" }
    assert_equal "812SH s2", handset.name
    user_agents_to_handsets = Hash.new {|h,k| h[k] = []}
    handsets.each do |h|
      user_agents_to_handsets[h.user_agent] << h
    end
    user_agents = user_agents_to_handsets.find_all {|k,v| v.size > 1 }.map {|k,v| k}
    assert_equal [], user_agents
  end
end

