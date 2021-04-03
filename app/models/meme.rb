class Meme < ApplicationRecord
  has_many :commands
  accepts_nested_attributes_for :commands, allow_destroy: true
  has_one_attached :audio
  validates :commands, presence: true
end
