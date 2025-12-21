class Message < ApplicationRecord
  belongs_to :stay
  belongs_to :user

  # ↓↓↓ これを追加（空のメッセージは禁止）
  validates :body, presence: true
end
