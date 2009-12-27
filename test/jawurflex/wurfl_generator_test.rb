$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..',  'lib')
require "rubygems"
require "test/unit"
require "hpricot"
require "wurfl/loader"
require "jawurflex/wurfl_generator"
require "tempfile"

class WurflGeneratorTest < Test::Unit::TestCase
  def setup
    # generate only once for performance
    unless defined?(@@handsets)
      @@handsets = nil
      base_wurfl = File.join(File.dirname(__FILE__), "..", "data", "wurfl.xml")
      @@base_handsets = Wurfl::Loader.new.load_wurfl(base_wurfl)
      patch = Tempfile.new("wurfl.patch.xml")
      Jawurflex::WurflGenerator.generate_wurfl(@@base_handsets, patch)
      patch.close
      loader = Wurfl::Loader.new
      loader.load_wurfl(base_wurfl)
      @@handsets = loader.load_wurfl(patch.path)
    end
    @base_handsets = @@base_handsets
    @handsets = @@handsets
    @patch_handests = @handsets.dup
  end

  def test_d501i
    device = @handsets['docomo_d501i_ver1']
    assert_equal "DoCoMo/1.0/D501i", device.user_agent
    assert_equal "96", device["max_image_width"]
  end

  def test_n_08a
    device = @handsets['docomo_n_08a_ver1']
    assert_equal "DoCoMo/2.0 N08A3", device.user_agent
    assert_equal "240", device["max_image_width"]
    assert_equal "320", device["max_image_height"]
  end

  def test_n_06a
    device = @handsets['docomo_n_06a_ver1']
    assert_equal "DoCoMo/2.0 N06A3", device.user_agent
  end

  def test_p_07a
    device = @handsets['docomo_p_07a_ver1']
    assert_equal "DoCoMo/2.0 P07A3", device.user_agent
    assert_equal "240", device["max_image_width"]
    assert_equal "331", device["max_image_height"]
    assert_equal "3_1", device["flash_lite_version"]
  end

  def test_pt35
    device = @handsets['kddi_pt35_ver1']
    assert_equal "230", device['max_image_width']
    assert_equal "324", device['max_image_height']
    assert_equal "400", device['wallpaper_max_height']
    assert_equal "KDDI-PT35 UP.Browser/6.2.0.15.1.1 (GUI) MMP/2.0", device.user_agent
  end

  def test_docomo_so905ics_ver1
    device = @handsets['docomo_so905ics_ver1']
    assert_equal "240", device['max_image_width']
    assert_equal "368", device['max_image_height']
    assert_equal "864", device['wallpaper_max_height']
    assert_equal "480", device['wallpaper_max_width']
  end

  def test_f_10a
    device = @handsets['docomo_f_10a_ver1']
    assert_equal "DoCoMo/2.0 F10A", device.user_agent
    assert_equal "240", device["max_image_width"]
    assert_equal "330", device["max_image_height"]
    assert_equal "3_0", device["flash_lite_version"]
    assert_equal "html_wi_imode_htmlx_2_2", device["preferred_markup"]
  end

  def test_width_and_height
    @handsets.each do |id, h|
      unless id =~ /generic/
        assert !h["max_image_width"].to_s.empty?, "#{id} does not have width"
        assert !h["max_image_height"].to_s.empty?, "#{id} does not have height"
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

  def test_docomo_generic_jap_ver1
    device = @handsets["docomo_generic_jap_ver1"]
    assert_equal "false", device["progressive_download"]
    assert_equal "none", device["playback_acodec_amr"]
    assert_equal "false", device["streaming_video"]
  end

  def test_docomo_generic_jap_ver2
    device = @handsets["docomo_generic_jap_ver2"]
    assert_equal "1", device["playback_vcodec_h264_bp"]
    assert_equal "true", device["progressive_download"]
    assert_equal "true", device["playback_3gpp"]
    assert_equal "nb", device["playback_acodec_amr"]
    assert_equal "lc", device["playback_acodec_aac"]
    assert_equal "false", device["streaming_video"]
  end

  def test_softbank_generic
    device = @handsets["softbank_generic"]
    assert_equal "10", device["playback_vcodec_h263_0"]
    assert_equal "true", device["playback_3gpp"]
    assert_equal "nb", device["playback_acodec_amr"]
  end

  def test_kddi_wap20_generic
    device = @handsets["kddi_wap20_generic"]
    assert_equal "1", device["playback_vcodec_mp4_sp"]
    assert_equal "true", device["progressive_download"]
    assert_equal "true", device["playback_3g2"]
    assert_equal "nb", device["playback_acodec_amr"]
    assert_equal "lc", device["playback_acodec_aac"]
    assert_equal "true", device["streaming_video"]
    assert_equal "true", device["streaming_3g2"]
    assert_equal "#{140*1024}", device["streaming_video_size_limit"]
  end

  def test_max_image_dimensions_less_than_resolution_dimensions
    handsets = @handsets.find_all do |id, h|
      !@base_handsets[id] && 
        %[width height].any? do |d|
          %w[max_image resolution].all? {|s| h["#{s}_#{d}"]} &&
            h["max_image_#{d}"] > h["resolution_#{d}"]
        end
    end
    assert_equal [], handsets.map {|a| a[0]}
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

