# frozen_string_literal: true
# A Meme
class Meme < ApplicationRecord
  include MemesHelper

  has_many :commands, dependent: :destroy
  has_one_attached :audio
  has_one_attached :audio_opus
  has_many :meme_tags
  has_many :tags, through: :meme_tags

  accepts_nested_attributes_for :commands, allow_destroy: true
  validates_associated :commands, :tags

  validates :name, presence: true, uniqueness: true
  validates :start,
            :end,
            format: {
              with: /\A(?:(?:\d{1,}:)?\d{1,2}:\d{2}(?:\.\d+)?|\d+(?:\.\d+)?)\z/,
              messgae: 'must have format [HH:]MM:SS[.m...] or S+[.m...]',
            },
            allow_blank: true
  validates :commands, presence: true
  validate :source_or_audio
  validate :source_url_is_from_youtube

  after_validation :format_source_url
  before_create :scrape_audio
  before_update :scrape_audio, if: :should_update_audio?

  before_destroy :remove_tags

  # Override save to handle commands not being unique
  def save(**options)
    super(**options)
  rescue ActiveRecord::RecordNotUnique
    errors.add(:commands, 'must be unique')
    false
  end

  def tags_attributes=(attributes)
    tags = attributes.values
    tags_d, tags_c =
      tags.partition do |tag|
        tag.key?('_destroy') ? tag['_destroy'].to_i.positive? : false
      end
    destroy_tag_associations(tags_d)
    create_tag_associations(tags_c)
  end

  def self.search(search)
    search.present? ? where('name LIKE ?', "%#{search}%") : all
  end

  private

  def create_tag_associations(tags)
    tags.each do |tag_attr|
      tag = Tag.find_or_create_by(name: tag_attr['name'])
      MemeTag.find_or_create_by({ meme: self, tag: tag })
    end
  end

  def destroy_tag_associations(tags)
    tags.each do |tag_attr|
      tag = Tag.find_by(name: tag_attr['name'])
      MemeTag.destroy_by({ meme: self, tag: tag })
      tag.destroy if MemeTag.where(tag: tag).count <= 0
    end
  end

  def source?
    source_url.present? && start.present? && self.end.present?
  end

  def audio?
    audio.attached? && audio_opus.attached?
  end

  def source_or_audio
    return if source? || audio?
    errors.add(:source_url, :blank) if source_url.blank?
    errors.add(:start, :blank) if start.blank?
    errors.add(:end, :blank) if self.end.blank?
  end

  def source_url_is_from_youtube
    return if source_url.blank?
    uri = URI(source_url)
    unless %w[youtube.com www.youtube.com youtu.be].include?(uri.host)
      errors.add(:source_url, 'must be from a youtube domain')
    end
    if get_video_id(uri).blank?
      errors.add(:source_url, 'must include a video id')
    end
  end

  def format_source_url
    return if errors.any? || source_url.blank?
    uri = URI(source_url)
    id = get_video_id(uri)
    self.source_url = "https://www.youtube.com/watch?v=#{id}"
  end

  def should_update_audio?
    source_url_changed? || start_changed? || end_changed?
  end

  def scrape_audio
    return unless source?
    set_path
    metadata = download_audio
    update_metadata(metadata)
    purge_old_audio
    attach_new_audio
    delete_local_audio
  end

  def set_path
    uuid = SecureRandom.uuid
    @path = "./tmp/#{uuid}.mp3"
    @path_opus = "./tmp/#{uuid}.opus"
  end

  def download_audio
    stdout, stderr, status = run_archiver
    if status.success?
      JSON.parse(stdout, { symbolize_names: true })
    else
      logger.debug stdout
      logger.error stderr
      errors.add(:base, 'Failed to scrape audio from source URL')
      throw :abort
    end
  end

  def run_archiver
    cmd = [
      'node',
      './lib/archiver.mjs',
      source_url,
      start,
      self.end,
      @path,
      @path_opus,
    ]
    Open3.capture3(cmd.join(' '))
  end

  def purge_old_audio
    audio.purge if audio.attached?
    audio_opus.purge if audio_opus.attached?
  end

  def attach_new_audio
    audio.attach(io: File.open(@path), filename: "#{name.parameterize}.mp3")
    audio_opus.attach(
      io: File.open(@path_opus),
      filename: "#{name.parameterize}.opus",
    )
  end

  def delete_local_audio
    File.delete(@path)
    File.delete(@path_opus)
  end

  def update_metadata(metadata)
    self.duration = duration_to_secs(metadata[:duration])
    self.loudness_i = metadata[:loudness][:i]
    self.loudness_lra = metadata[:loudness][:lra]
    self.loudness_tp = metadata[:loudness][:tp]
    self.loudness_thresh = metadata[:loudness][:thresh]
  end

  def remove_tags
    destroy_tag_associations(tags)
  end
end
