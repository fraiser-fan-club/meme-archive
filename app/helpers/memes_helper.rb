module MemesHelper
  def duration_to_secs(duration)
    h, m, s = duration.split(':').map { |str| str.to_f }
    h * 3600 + m * 60 + s
  end

  def get_video_id(uri)
    case uri.host
    when 'youtube.com', 'www.youtube.com'
      return unless uri.query
      params = Hash[URI.decode_www_form(uri.query)]
      params['v']
    when 'youtu.be'
      uri.path.split('/')[1]
    end
  end
end
