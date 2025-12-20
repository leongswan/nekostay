class Pet < ApplicationRecord
  belongs_to :user
  has_many :stays
  
  # ↓↓↓ この1行を追加してください！ ↓↓↓
  has_one_attached :image
  # --------------------------------
end
