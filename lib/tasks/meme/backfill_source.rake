require_relative 'meme_filler'
require Rails.root.join('app/helpers/memes_helper')
include MemesHelper

namespace :meme do
  desc 'Backfill source url from legacy memebot'
  task :backfill_source_url, %i[offset limit] => :environment do |_, args|
    filler = MemeFiller.new(args)
    filler.process { |meme_attrs| update_source(meme_attrs) }
  end
end

def update_source(meme_attrs)
  attrs = source_attrs(meme_attrs)
  return if attrs.empty?
  meme = Meme.find_by(name: meme_attrs['name'])
  meme.update_columns(attrs)
end

def source_attrs(meme_attrs)
  {
    source_url: format_source_url(meme_attrs['sourceURL']),
    start: meme_attrs['start'],
    end: meme_attrs['end'],
  }.keep_if { |_, value| value.present? }
end

def format_source_url(url)
  return if url.blank?
  id = MemesHelper.get_video_id(URI(url))
  "https://www.youtube.com/watch?v=#{id}"
end
