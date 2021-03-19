module MemesHelper
  def durationToSecs(duration)
    # 00:00:03.00
    h,m,s = duration.split(':').map {|str| str.to_f}
    secs = 0
    secs += h * 3600
    secs += m * 60
    secs += s
  end
end
