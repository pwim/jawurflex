$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..', '..',  'lib')
require "test/unit"
require "jawurflex/handset/au_handset"

class AuHandsetTest < Test::Unit::TestCase
  def test_parse_handsets
    handsets = Jawurflex::Handset::AuHandset.parse_handsets

    ts25_handsets = handsets.find_all {|h| h.device_id == "TS25"}
    assert_equal 1, ts25_handsets.size
    h = ts25_handsets.first
    assert_equal "A1304T II", h.name
    assert_equal 65536, h.colors
    assert_equal 144, h.browser_width
    assert_equal 140, h.browser_height
    assert_equal 144, h.physical_width
    assert_equal 176, h.physical_height

    h = handsets.find {|h| h.name == "A1303SA" }
    assert_equal 26*10000, h.colors

    h = handsets.find {|h| h.name == "A5512CA" }
    assert_equal 6*10_000+5*1000, h.colors

    h = handsets.find {|h| h.name == "A5522SA" }
    assert_equal 262114, h.colors

    h = handsets.find {|h| h.device_id == "PT35" }
    assert_equal "NS02", h.name
    assert_equal 230, h.browser_width
    assert_equal 324, h.browser_height
    assert_equal 240, h.physical_width
    assert_equal 400, h.physical_height
  end
end

