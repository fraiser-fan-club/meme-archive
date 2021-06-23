require 'json/add/date_time'
require Rails.root.join('app/helpers/memes_helper')
include MemesHelper

namespace :meme do
  desc 'Adds meme from legacy memebot'
  task :backfill, %i[offset limit] => :environment do |_, args|
    filler = MemeFiller.new(args)
    filler.process { |meme_attrs| create_meme(meme_attrs) }
  end
end

def create_meme(meme_attributes)
  return if Meme.find_by({ name: meme_attributes['name'] })
  meme = build_meme(meme_attributes)
  create_commands(meme, meme_attributes)
  create_tags(meme, meme_attributes)
  attach_audio(meme)
  meme.save!(validate: false)
end

def build_meme(meme_attributes)
  loudness = meme_attributes['loudness']
  Meme.insert(
    {
      name: meme_attributes['name'],
      private: meme_attributes['private'],
      created_at: get_created_at(meme_attributes),
      updated_at: DateTime.now,
      duration: duration_to_secs(meme_attributes['duration']),
      loudness_i: loudness['i'],
      loudness_lra: loudness['lra'],
      loudness_tp: loudness['tp'],
      loudness_thresh: loudness['thresh'],
    },
  )
  Meme.find_by(name: meme_attributes['name'])
end

def get_created_at(meme_attributes)
  if meme_attributes['createdAt'].is_a?(String)
    meme_attributes['createdAt']
  else
    meme_attributes['createdAt']['$date']
  end
end

def attach_audio(meme)
  url =
    "https://memebot.nyc3.digitaloceanspaces.com/memebot/audio/#{meme.name}.opus"
  IO.copy_stream(URI.parse(url).open, 'tmp/audio.opus')
  `ffmpeg -i tmp/audio.opus tmp/audio.mp3 -hide_banner -loglevel error`
  meme.audio_opus.attach(
    io: File.open('tmp/audio.opus'),
    filename: "#{meme.name.parameterize}.opus",
  )
  meme.audio.attach(
    io: File.open('tmp/audio.mp3'),
    filename: "#{meme.name.parameterize}.mp3",
  )
  File.delete('tmp/audio.opus', 'tmp/audio.mp3')
end

def create_commands(meme, attrs)
  commands = [*attrs['aliases'], attrs['name']]
  commands.map { |command| Command.create(name: command, meme: meme) }
end

def create_tags(meme, attrs)
  attrs['tags'].map do |tag|
    tag = Tag.find_or_create_by(name: tag)
    MemeTag.create(meme: meme, tag: tag)
  end
end
