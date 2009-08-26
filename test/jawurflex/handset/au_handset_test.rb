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

    h = handsets.find {|h| h.name == "A1303SA" }
    assert_equal 26*10000, h.colors

    h = handsets.find {|h| h.name == "A5512CA" }
    assert_equal 6*10_000+5*1000, h.colors

    h = handsets.find {|h| h.name == "A5522SA" }
    assert_equal 262114, h.colors
  end
end

