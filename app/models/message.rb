class Message < ApplicationRecord
  # 関連付け
  belongs_to :stay
  belongs_to :sender,   class_name: "User"
  belongs_to :receiver, class_name: "User"

  # バリデーション
  validates :body, presence: true
  
  # スコープ
  scope :recent, -> { order(created_at: :asc) }
end