$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..',  'lib')
require "rubygems"
require "test/unit"
require "hpricot"
require "wurfl/loader"
require "jawurflex/wurfl_generator"

class WurflGeneratorTest < Test::Unit::TestCase
  def setup
    # generate only once for performance
    unless defined?(@@handsets)
      loader = Wurfl::Loader.new
      s = Jawurflex::WurflGenerator.generate_wurfl
      patch_handsets, fallbacks = loader.parse_xml(s)
      @@patch_handsets = patch_handsets.keys
      @@handsets, fallbacks = loader.load_wurfl(File.join(File.dirname(__FILE__), "..", "data", "wurfl.xml"))
    end
    @handsets = @@handsets
  end

  def test_d501i
    device = @handsets['docomo_d501i_ver1']
    assert_equal "DoCoMo/1.0/D501i", device.user_agent
    assert_equal "96", device["resolution_width"]
  end

  def test_n_08a
    device = @handsets['docomo_n_08a_ver1']
    assert_equal "DoCoMo/2.0 N08A", device.user_agent
    assert_equal "240", device["resolution_width"]
    assert_equal "320", device["resolution_height"]
  end

  def test_n_06a
    device = @handsets['docomo_n_06a_ver1']
    assert_equal "DoCoMo/2.0 N06A3", device.user_agent
  end

  def test_p_07a
    device = @handsets['docomo_p_07a_ver1']
    assert_equal "DoCoMo/2.0 P07A3", device.user_agent
    assert_equal "240", device["resolution_width"]
    assert_equal "331", device["resolution_height"]
    assert_equal "3.1", device["flash_lite_version"]
  end

  def test_width_and_height
    @handsets.each do |id, h|
      unless id =~ /generic/
        assert !h["resolution_width"].to_s.empty?, "#{id} does not have width"
        assert !h["resolution_height"].to_s.empty?, "#{id} does not have height"
      end
    end
  end
end

