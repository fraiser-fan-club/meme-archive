class Tag < ApplicationRecord
  has_many :meme_tags
  has_many :memes, through: :meme_tags
  validates :name, presence: true, uniqueness: true
end
