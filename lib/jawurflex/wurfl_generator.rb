require "rubygems"
require "builder"
require "jawurflex/handset/softbank_handset"
require "jawurflex/handset/au_handset"
require "jawurflex/handset/docomo_handset"
require "jawurflex/wurfl_mapper"

class Jawurflex::Handset
  attr_accessor :wurfl_id
end

class Jawurflex::WurflGenerator

  def self.generate_wurfl(base_wurfl_handsets, target)
    wurfl_mapper = Jawurflex::WurflMapper.new

    generic_xhtml = Jawurflex::Handset.new(
      :wurfl_id => "generic_xhtml",
      :markup => [ "html_wi_oma_xhtmlmp_1_0" ])


    base_softbank = Jawurflex::Handset::SoftbankHandset.new(
      :wurfl_id => "softbank_generic",
      :markup => [ "softbank_xhtml_mp" ],
      :user_agent => "SoftBank/1.0",
      :browser_width => 240,
      :browser_height => 320, # The most common value is 350, but this is larger then physical_height
      :physical_height => 320,
      :physical_width => 240,
      :colors => 262144,
      :playback_3gpp => true,
      :playback_vcodec_h263_0=> 10,
      :playback_acodec_amr => "nb")

    base_au = Jawurflex::Handset::AuHandset.new(
      :wurfl_id => "kddi_wap20_generic",
      :markup => [ "au_xhtml_mp" ],
      :user_agent => "KDDI",
      :browser_width => 232,
      :browser_height => 320,
      :wallpaper_max_width => 240,
      :wallpaper_max_height => 320,
      :colors => 65536,
      :playback_acode_qcelp => true,
      :playback_3g2 => true,
      :playback_acodec_amr => "nb",
      :playback_acodec_aac => "lc",
      :progressive_download => true,
      :playback_vcodec_mp4_sp => "1",
      :streaming_video => true,
      :streaming_3g2 => true,
      :streaming_video_size_limit => 140*1024)

    base_docomo_fallback = Jawurflex::Handset::DocomoHandset.new(
      :wurfl_id => "docomo_generic_jap_ver1",
      :markup => [ "docomo_imode_html_1" ],
      :browser_width => 240,
      :browser_height => 144,
      :wallpaper_max_width => 240,
      :wallpaper_max_height => 320,
      :colors => 65536,
      :streaming_video => false)

    base_docomo = Jawurflex::Handset::DocomoHandset.new(
      :wurfl_id => "docomo_generic_jap_ver2",
      :markup => [ "docomo_imode_html_3" ],
      :user_agent => "DoCoMo/2.0",
      :browser_height => 320,
      :colors => 262144,
      :playback_3gpp => true,
      :playback_acodec_amr => "nb",
      :playback_acodec_aac => "lc",
      :progressive_download => true,
      :playback_vcodec_h264_bp => "1")

    base_docomo_2_0_browser = Jawurflex::Handset::DocomoHandset.new(
      :wurfl_id => "docomo_2_0_browser_ver1",
      :user_agent => "Generic docomo 2.0 browser",
      :markup => [ "imode_browser_2_0_xhtml"],
      :browser_width => 240,
      :browser_height => 320,
      :wallpaper_max_width => 480,
      :wallpaper_max_height => 854,
      :colors => 262144,
      :flash_lite => "3.1",
      :playback_3gpp => true,
      :playback_acodec_amr => true,
      :playback_acodec_aac => "heaac",
      :progressive_download => true,
      :playback_vcodec_h264_bp => "1.3",
      :streaming_video => false)

    b = Builder::XmlMarkup.new(:indent => 2, :target => target)
    xml = b.wurfl_patch do |b|
      b.version do |b|
        t = Time.now
        b.ver("jawurflex - " << t.strftime("%Y-%m-%d %H:%M:%S"))
        b.last_updated(t.to_s)
        b.maintainers do |b|
          b.maintainer(:name => "mobalean",
                       :email => "info@mobalean.com",
                       :home_page => "http://www.mobalean.com")
        end
      end
      b.devices do |b|
        wurfl_mapper.wurfl_entry(b, base_softbank, generic_xhtml, false)
        Jawurflex::Handset::SoftbankHandset.parse_handsets.each do |h|
          wurfl_mapper.wurfl_entry(b, h, base_softbank, true)
        end

        wurfl_mapper.wurfl_entry(b, base_au, generic_xhtml, false)
        Jawurflex::Handset::AuHandset.parse_handsets.each do |h|
          base_handset = base_wurfl_handsets[wurfl_mapper.wurfl_id(h)]
          if base_handset && base_handset.user_agent =~ /UP.Browser/
            h.user_agent = base_handset.user_agent
          end
          wurfl_mapper.wurfl_entry(b, h, base_au, true)
        end

        wurfl_mapper.wurfl_entry(b, base_docomo, base_docomo_fallback, false)
        wurfl_mapper.wurfl_entry(b, base_docomo_2_0_browser, generic_xhtml, false)
        Jawurflex::Handset::DocomoHandset.parse_handsets.each do |h|

          fallback = if h.markup.first == "imode_browser_2_0_xhtml"
            base_docomo_2_0_browser
          elsif h.user_agent =~ /#{base_docomo.user_agent}/
            base_docomo
          else
            base_docomo_fallback
          end
          wurfl_mapper.wurfl_entry(b, h, fallback, true)
        end
      end
    end
  end
end
