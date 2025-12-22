class Review < ApplicationRecord
  # どの予約に対する評価か
  belongs_to :stay
  
  # 評価した人（飼い主）
  belongs_to :rater, class_name: "User"
  
  # 評価された人（シッター）
  belongs_to :ratee, class_name: "User"

  # バリデーション（入力チェック）
  validates :score, presence: true, inclusion: { in: 1..5 } # 星は1〜5まで
  validates :comment, length: { maximum: 500 } # コメントは500文字まで
end