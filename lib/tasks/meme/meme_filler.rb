require 'json/add/date_time'

# Backfills memes
class MemeFiller
  URL = 'https://memebot.nyc3.digitaloceanspaces.com/memebot/memes.json'.freeze

  def initialize(args)
    @first = args.offset.blank? ? 0 : args.offset.to_i
    @last = args.limit.blank? ? -1 : @first + args.limit.to_i - 1
    fetch
  end

  def process
    puts "Processing memes from #{@first} to #{@last}"
    @memes.each_index do |index|
      meme = @memes[index]
      print "#{index + @first} #{meme['name']}"
      status = yield meme
      puts " #{status ? color('✔', 32) : color('✘', 31)}"
    end
  end

  #private

  def fetch
    memes = JSON.parse(URI.parse(URL).open.read, create_additions: true)
    @memes = memes[@first..@last]
  end

  def color(str, color)
    "\e[#{color}m#{str}\e[0m"
  end
end
