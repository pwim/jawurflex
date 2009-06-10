$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..', '..',  'lib')
require "test/unit"
require "jawurflex/handset/docomo_handset"

class DocomoHandsetTest < Test::Unit::TestCase
  def test_parse_handsets
    handsets = Jawurflex::Handset::DocomoHandset.parse_handsets

    h = handsets.find {|h| h.device_id == "D501i"}
    assert_equal "D501i", h.name
    assert_equal 96, h.browser_width
    assert_equal 72, h.browser_height
    assert_equal 2, h.colors
    assert_equal ["imode_html_1_0"], h.markup
    assert_nil h.flash_lite

    h = handsets.find {|h| h.device_id == "D502i"}
    assert_equal 256, h.colors

    h = handsets.find {|h| h.device_id == "SH706iw"}
    assert_equal ["imode_xhtml_2_3", "imode_html_7_2"], h.markup
    assert_equal "3.0", h.flash_lite

    h = handsets.find {|h| h.device_id == "L-03A"}
    assert_equal ["imode_xhtml_2_0", "imode_html_6_0", ], h.markup
    assert_equal 240, h.browser_width
    assert_equal 280, h.browser_height
    assert_equal 240, h.display_width
    assert_equal 320, h.display_height

    h = handsets.find {|h| h.device_id == "N-08A"}
    assert_equal ["imode_browser_2_0_xhtml"], h.markup
    assert_equal 240, h.browser_width
    assert_equal 320, h.browser_height
    assert_equal 480, h.display_width
    assert_equal 854, h.display_height

    valid_xhtml_markup_types = ["1_0", "1_1", "2_0", "2_1", "2_2", "2_3" ].
      map {|i| "imode_xhtml_#{i}"}
    valid_html_markup_types = (1..7).
      map {|i| "imode_html_#{i}_0"} + ["imode_html_7_1", "imode_html_7_2" ]
    valid_markup_types = valid_xhtml_markup_types + valid_html_markup_types + 
      [ "imode_browser_2_0_xhtml"]
    handsets.each do |h|
      h.markup.each do |m|
        assert valid_markup_types.include?(m), "#{h.device_id}: #{m} does not exist"
      end
    end
  end

end

