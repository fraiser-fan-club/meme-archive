# frozen_string_literal: true
# A Meme
class Meme < ApplicationRecord
  include MemesHelper

  has_many :commands
  has_one_attached :audio
  has_one_attached :audio_opus
  has_many :meme_tags
  has_many :tags, through: :meme_tags

  accepts_nested_attributes_for :commands, allow_destroy: true
  accepts_nested_attributes_for :tags, allow_destroy: true
  validates_associated :commands, :tags

  validates :name, presence: true, uniqueness: true
  validates :source_url, presence: true
  validates :start,
            :end,
            presence: true,
            format: {
              with: /\A(?:(?:\d{1,}:)?\d{1,2}:\d{2}(?:\.\d+)?|\d+(?:\.\d+)?)\z/,
              messgae: 'must have format [HH:]MM:SS[.m...] or S+[.m...]',
            }
  validates :commands, presence: true
  validate :source_url_is_from_youtube

  after_validation :format_source_url
  before_create :scrape_audio
  before_update :scrape_audio, if: :should_update_audio?

  # Override save to handle commands not being unique
  def save(**options)
    super(**options)
  rescue ActiveRecord::RecordNotUnique
    errors.add(:commands, 'must be unique')
    false
  end

  private

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

  def format_source_url
    return if errors.any?
    uri = URI(source_url)
    id = get_video_id(uri)
    self.source_url = "https://www.youtube.com/watch?v=#{id}"
  end

  def should_update_audio?
    source_url_changed? || start_changed? || end_changed?
  end

  def scrape_audio
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
end
