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
      base_wurfl = File.join(File.dirname(__FILE__), "..", "data", "wurfl.xml") 
      @@base_handsets, fallbacks = Wurfl::Loader.new.load_wurfl(base_wurfl)
      s = Jawurflex::WurflGenerator.generate_wurfl(@@base_handsets)
      loader = Wurfl::Loader.new
      loader.load_wurfl(base_wurfl)
      @@handsets, fallbacks = loader.parse_xml(s)
    end
    @base_handsets = @@base_handsets
    @handsets = @@handsets
  end

  def test_d501i
    device = @handsets['docomo_d501i_ver1']
    assert_equal "DoCoMo/1.0/D501i", device.user_agent
    assert_equal "96", device["resolution_width"]
  end

  def test_n_08a
    device = @handsets['docomo_n_08a_ver1']
    assert_equal "DoCoMo/2.0 N08A3", device.user_agent
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
    assert_equal "3_1", device["flash_lite_version"]
  end

  def test_pt35
    device = @handsets['kddi_pt35_ver1']
    assert_equal "230", device['resolution_width']
    assert_equal "324", device['resolution_height']
    assert_equal "400", device['max_image_height']
    assert_equal "KDDI-PT35 UP.Browser/6.2.0.15.1.1 (GUI) MMP/2.0", device.user_agent
  end

  def test_docomo_so905ics_ver1
    device = @handsets['docomo_so905ics_ver1']
    assert_equal "864", device['max_image_height']
    assert_equal "480", device['max_image_width']
    assert_equal "240", device['resolution_width']
    assert_equal "368", device['resolution_height']
  end

  def test_width_and_height
    @handsets.each do |id, h|
      unless id =~ /generic/
        assert !h["resolution_width"].to_s.empty?, "#{id} does not have width"
        assert !h["resolution_height"].to_s.empty?, "#{id} does not have height"
      end
    end
  end

  def test_user_agent_doesn_t_differ
    @handsets.each do |id, h|
      base = @base_handsets[id]
      if base && !bad_base_user_agent?(base)
        assert_equal base.user_agent, h.user_agent
      end
    end
  end

  def bad_base_user_agent?(h)
    @uas ||= { 
      "SoftBank/1.0/921P/PJP10/SN353701021200197 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/823SH/SHJ001/SN358030010389935 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/DM002SH/SHJ001/SNXXXXXXXXXXXXXXX Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/830P/PJP10/SNXXXXXXXXXXXXXXX Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/920T/TJ001/SNXXXXXXXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/923SH/SHJ001/SN353680020578631 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/813T/TJ001/SN354950014037939 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/705P/PJP10/SN359488001765860 Browser/Teleca-Browser/3.1 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/825SH/SHJ001/SN353679021018514 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/824SH/SHJ001/SNXXXXXXXXXXXXXXX Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/830T/TJ001/SNXXXXXXXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/912SH/SHJ001/SN353689010176272 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/810SH/SHJ002/SN359797002111241 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/930SC/SCJ001/SNXXXXXXXXXXXXXXX Browser/NetFront/3.4" => true,
      "Mozilla/4.08 (930CA;SoftBank;SNXXXXXXXXXXXXXXX) NetFront/3.4" => true,
      "SoftBank/1.0/816SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/811SH/SHJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/815T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/821SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/922SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/805SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/912T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/913SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/911SH/SHJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "Mozilla/4.08 (815SH;SoftBank) NetFront/3.4" => true,
      "SoftBank/1.0/709SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/921SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/820SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/820P/PJP10 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/910SH/SHJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/921T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/708SC/SCJ001 Browser/NetFront/3.3" => true,
      "SoftBank/1.0/920P/PJP11 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/706SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/814T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/707SC2/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/811T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/814SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/812SH/SHJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/810P/PJP10 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/911T/TJ002 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/707SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/810T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/920SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/920SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/822SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/820SH/SHJ001 Browser/NetFront/3.4 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "SoftBank/1.0/705SC/SCJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" => true,
      "DoCoMo/1.0/P506iC/c20/TB/W30H14" => true,
      "DoCoMo/2.0 F704i(c100;TB;W23H12)" => true,
      "DoCoMo/2.0 L602i(c100;TB;W21H11)" => true,
      "Mozilla/4.08 (N905i;FOMA;c500;TB)" => true,
      "Mozilla/5.0 (SO905i; FOMA; like Gecko)" => true,
      "Mozilla/4.08 (N706i;FOMA;c500;TB)" => true,
      "Mozilla/5.0 (F906i;FOMA;like Gecko)" => true,
      "Mozilla/4.08 (D903i;FOMA;c300;TB)" => true,
      "Mozilla/4.08 (F903i;FOMA;c300;TB)" => true,
      "Mozilla/5.0 (SH906i;FOMA;like Gecko)" => true,
      "Mozilla/4.08 (D904i;FOMA;c500;TB)" => true,
      "Mozilla/5.0 (SO905iCS; FOMA; like Gecko)" => true,
      "Mozilla/4.08 (F904i;FOMA;c500;TB)" => true,
      "Mozilla/4.08 (P905iTV;FOMA;c500;TB)" => true,
      "Mozilla/4.08 (N904i_W;FOMA;c500;TB)" => true,
      "Mozilla/5.0 (F905i;FOMA;like Gecko)" => true,
      "Mozilla/5.0 (N906i;FOMA;like Gecko)" => true,
    }
    @uas[h.user_agent]
  end
end

