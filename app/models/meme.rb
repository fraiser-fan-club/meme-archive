class Meme < ApplicationRecord
  has_many :commands, validate: true
  accepts_nested_attributes_for :commands, allow_destroy: true
  has_one_attached :audio

  validates :name, presence: true, uniqueness: true
  validates :source_url, presence: true
  validates :start, :end, presence: true,
    format: {
      with: /\A(?:(?:\d{1,}:)?\d{1,2}:\d{2}(?:\.\d+)?|\d+(?:\.\d+)?)\z/, messgae: "must have format [HH:]MM:SS[.m...] or S+[.m...]"
    }
  validates :commands, presence: true
  validate :source_url_is_from_youtube

  after_validation :format_source_url

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
end
