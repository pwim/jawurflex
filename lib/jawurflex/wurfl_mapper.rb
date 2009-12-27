require "jawurflex"
class Jawurflex::WurflMapper
  def self.wurfl_mapping(handset_attribute, wurfl_attribute)
    define_method(wurfl_attribute) do |handset|
      handset.send(handset_attribute)
    end
  end

  def self.capabilitity_group(name, mappings)
    mappings.each {|k,v| wurfl_mapping(k,v)}
    capabilitity_groups[name] = mappings.values
  end

  def self.capabilitity_groups
    @groups ||= {}
  end

  capabilitity_group("image_format",
                     :colors => :colors)
  capabilitity_group("display",
                     :physical_width => :resolution_width,
                     :physical_height => :resolution_height,
                     :browser_width => :max_image_width,
                     :browser_height => :max_image_height)
  capabilitity_group("product_info",
                     :brand_name => :brand_name,
                     :name => :model_name)
  capabilitity_group("flash_lite",
                     :flash_lite => :flash_lite_version)
  capabilitity_group("xhtml_ui",
                     :xhtml_table_support => :xhtml_table_support)
  capabilitity_group("markup",
                     :markup => :preferred_markup)
  capabilitity_group("playback",
                     :playback_3gpp => :playback_3gpp,
                     :playback_3g2 => :playback_3g2,
                     :playback_acodec_amr => :playback_acodec_amr,
                     :playback_acodec_aac => :playback_acodec_aac,
                     :playback_acode_qcelp => :playback_acode_qcelp,
                     :progressive_download => :progressive_download,
                     :playback_vcodec_h264_bp => :playback_vcodec_h264_bp,
                     :playback_vcodec_mp4_sp => :playback_vcodec_mp4_sp,
                     :playback_vcodec_h263_0 => :playback_vcodec_h263_0)
  capabilitity_group("streaming",
                     :playback_vcodec_mp4_sp => :playback_vcodec_mp4_sp,
                     :streaming_video => :streaming_video,
                     :streaming_3g2 => :streaming_3g2,
                     :streaming_video_size_limit => :streaming_video_size_limit)

  def wurfl_entry(b, handset, fallback, actual_device_root)
    h = { :user_agent => handset.user_agent,
          :fall_back => wurfl_id(fallback),
          :id => wurfl_id(handset)}
    h[:actual_device_root] = "true" if actual_device_root
    b.device(h) do |b|
      self.class.capabilitity_groups.each do |g,names|
        capabilitities(b,handset,fallback,g, *names)
      end
    end
  end

  def capabilitities(b, handset, fallback, group_id, *names)
    different = names.find_all do |n| 
      value = send(n, handset)
      fallback_value = send(n, fallback)
      !value.to_s.empty? && value != fallback_value
    end
    unless different.empty?
      b.group(:id => group_id) do |b|
        different.each do |n|
          v = send(n, handset)
          b.capability(:name => n, :value => v) unless v.to_s.empty?
        end
      end
    end
  end

  def wurfl_id(handset)
    handset.wurfl_id ?
      handset.wurfl_id :
      "#{handset.brand_name.downcase}_#{handset.device_id.tr(" -", "_").downcase}_ver1"
  end

  def preferred_markup(handset)
    case handset.markup.first
    when /imode_html_(\d)_(\d)/
      "html_wi_imode_html_#{$1}" << ($2.to_i == 0 ? "" : "_#{$2}")
    when /imode_xhtml_(\d)_(\d)/
      "html_wi_imode_htmlx_#{$1}" << ($2.to_i == 0 ? "" : "_#{$2}")
    when /xhtml/
      "html_wi_oma_xhtmlmp_1_0"
    when "mml"
      "html_wi_mml_html"
    else
      handset.markup.first
    end
  end

  undef :flash_lite_version
  def flash_lite_version(handset)
    handset.flash_lite && handset.flash_lite.tr(".","_")
  end

end
