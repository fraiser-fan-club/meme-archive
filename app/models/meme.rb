class Meme < ApplicationRecord
  include MemesHelper

  has_many :commands
  has_one_attached :audio
  has_many :meme_tags
  has_many :tags, through: :meme_tags
  
  accepts_nested_attributes_for :commands, allow_destroy: true
  accepts_nested_attributes_for :tags, allow_destroy: true
  
  validates_associated :commands, :tags
  validates :name, presence: true, uniqueness: true
  validates :source_url, presence: true
  validates :start, :end, presence: true,
    format: {
      with: /\A(?:(?:\d{1,}:)?\d{1,2}:\d{2}(?:\.\d+)?|\d+(?:\.\d+)?)\z/, messgae: "must have format [HH:]MM:SS[.m...] or S+[.m...]"
    }
  validates :commands, presence: true
  validate :source_url_is_from_youtube

  after_validation :format_source_url
  before_create :set_video
  before_update :set_video,
    if: Proc.new { source_url_changed? || start_changed? || end_changed? }

  # Override save to handle commands not being unique
  def save
    begin
      super
    rescue ActiveRecord::RecordNotUnique
      errors.add(:commands, "must be unique")
      false
    end
  end

  private

    def source_url_is_from_youtube
      uri = URI(source_url)
      if %w(youtube.com www.youtube.com).none?(uri.host)
        errors.add(:source_url, "must be from a youtube domain")
      end
      params = Hash[URI.decode_www_form(uri.query)]
      if !params.include?("v")
        errors.add(:source_url, "must include a video id param")
      end
    end

    def format_source_url
      uri = URI(source_url)
      params = Hash[URI.decode_www_form(uri.query)]
      id = params["v"]
      self.source_url = "https://www.youtube.com/watch?v=#{id}"
    end

    def set_video
      uuid = SecureRandom.uuid
      path = "./tmp/#{uuid}.mp3"
      metadata = `node ./lib/archiver.mjs #{self.source_url} #{self.start} #{self.end} #{path}`
      metadata = JSON.parse(metadata, {symbolize_names: true})
      self.duration = durationToSecs(metadata[:duration])
      self.loudness_i = metadata[:loudness][:i]
      self.loudness_lra = metadata[:loudness][:lra]
      self.loudness_tp = metadata[:loudness][:tp]
      self.loudness_thresh = metadata[:loudness][:thresh]
      if self.audio.attached?
        self.audio.purge
      end
      self.audio.attach(io: File.open(path), filename: "#{self.name.parameterize}.mp3")
      File.delete(path)
    end
end
