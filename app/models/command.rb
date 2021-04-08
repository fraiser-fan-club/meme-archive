class Command < ApplicationRecord
  belongs_to :meme
  validates :name, presence: true, uniqueness: true
end
