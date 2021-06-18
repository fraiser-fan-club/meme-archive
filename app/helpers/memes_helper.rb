module MemesHelper
  def duration_to_secs(duration)
    h, m, s = duration.split(':').map { |str| str.to_f }
    h * 3600 + m * 60 + s
  end
end
