class Meme < ApplicationRecord
  has_many :commands
  has_one_attached :audio
end
