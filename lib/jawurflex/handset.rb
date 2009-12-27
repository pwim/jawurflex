require "jawurflex"
class Jawurflex::Handset
  attr_accessor :device_id, :user_agent, :physical_width, :physical_height,
    :browser_width, :browser_height, :flash_lite, :brand_name, :markup,
    :xhtml_table_support, :name, :colors, :playback_3gpp, :playback_acodec_amr,
    :playback_acodec_aac, :progressive_download, :playback_vcodec_h264_bp,
    :playback_acode_qcelp, :progressive_download, :playback_vcodec_mp4_sp,
    :streaming_video, :streaming_3g2, :playback_3g2, 
    :streaming_video_size_limit, :playback_vcodec_h263_0,
    :wallpaper_max_width, :wallpaper_max_height

  def initialize(args={})
    args.each {|k,v| send("#{k}=", v)}
    @markup ||= []
  end
end

