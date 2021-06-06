require 'json/add/date_time'
require "#{Rails.root}/app/helpers/memes_helper"
include MemesHelper

memes_source_url =
  'https://memebot.nyc3.digitaloceanspaces.com/memebot/memes.json'
meme_url_prefix = 'https://memebot.nyc3.digitaloceanspaces.com/memebot/audio/'

namespace :active_record do
  desc 'Adds meme from legacy memebot'
  task add_memes: :environment do
    memes = JSON.parse(URI.open(meme_source_url).read, create_additions: true)
    memes
      .first(2)
      .each do |meme|
        commands =
          meme['commands'].map { |command| Command.create(name: command) }
        tags = meme['tags'].map { |tag| Tag.find_or_create_by(name: tag) }
        newMeme =
          Meme.upsert(
            name: meme['name'],
            private: meme['private'],
            created_at: meme['createdAt'],
            updated_at: DateTime.now,
            commands: commands,
            tags: tags,
            duration: durationToSecs(meme['duration']),
            loudness_i: meme['loudness']['i'],
            loudness_lra: meme['loudness']['lra'],
            loudness_tp: meme['loudness']['tp'],
            loudness_thresh: meme['loudness']['thresh'],
          )
        meme_url = meme_url_prefix + meme['name'] + '.opus'
        newMeme.audio.attach(
          io: URI.open.read,
          filename: "#{name.parameterize}.mp3",
        )
      end
  end
end
