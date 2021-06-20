require 'json/add/date_time'
require Rails.root.join('app/helpers/memes_helper')
include MemesHelper

namespace :active_record do
  desc 'Adds meme from legacy memebot'
  task add_memes: :environment do
    meme_source_url =
      'https://memebot.nyc3.digitaloceanspaces.com/memebot/memes.json'
    memes =
      JSON.parse(URI.parse(meme_source_url).open.read, create_additions: true)
    memes.each { |meme| create_meme(meme) }
  end
end

def create_meme(meme)
  upsert_meme(meme)
  name = meme['name']
  new_meme = Meme.find_by(name: name)
  create_commands(new_meme, [*meme['aliases'], name])
  create_tags(new_meme, meme['tags'])
  meme_url_prefix = 'https://memebot.nyc3.digitaloceanspaces.com/memebot/audio/'
  meme_url = "#{meme_url_prefix}#{name}.opus"
  IO.copy_stream(URI.parse(meme_url).open, 'tmp/test.opus')
  `ffmpeg -i tmp/test.opus tmp/test.mp3 -hide_banner -loglevel error`
  new_meme.updated_at = DateTime.now
  new_meme.audio_opus.attach(
    io: File.open('tmp/test.opus'),
    filename: "#{name.parameterize}.opus",
  )
  new_meme.audio.attach(
    io: File.open('tmp/test.mp3'),
    filename: "#{name.parameterize}.mp3",
  )
  File.delete('tmp/test.opus', 'tmp/test.mp3')
  new_meme.save(validate: false)
  puts name
end

# rubocop:disable Rails/SkipsModelValidations
def upsert_meme(meme)
  Meme.upsert(
    {
      name: meme['name'],
      private: meme['private'],
      created_at: meme['createdAt'],
      updated_at: DateTime.now,
      duration: duration_to_secs(meme['duration']),
      loudness_i: meme['loudness']['i'],
      loudness_lra: meme['loudness']['lra'],
      loudness_tp: meme['loudness']['tp'],
      loudness_thresh: meme['loudness']['thresh'],
    },
    unique_by: [:name]
  )
end
# rubocop:enable Rails/SkipsModelValidations

def create_commands(meme, commands)
  commands.map { |command| Command.create(name: command, meme_id: meme.id) }
end

def create_tags(meme, tags)
  tags.map do |tag|
    tag = Tag.find_or_create_by(name: tag)
    MemeTag.create(meme_id: meme.id, tag_id: tag.id)
  end
end
