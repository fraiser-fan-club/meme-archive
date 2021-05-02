class MemeTag < ApplicationRecord
  belongs_to :meme
  belongs_to :tag
  validates :tag, uniqueness: { scope: :meme }
end
