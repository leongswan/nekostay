class User < ApplicationRecord
  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 権限設定
  enum role: { owner: 0, sitter: 1, admin: 2 }, _prefix: true

  # プロフィール画像（ビューで image を使っているので image に統一します）
  has_one_attached :image

  # --- 関連付け（リレーション） ---

  # 1. ペットとの関連
  has_many :pets, dependent: :destroy

  # 2. 予約（自分が飼い主として作成したもの）
  #    Stayモデルは owner_id で飼い主を管理しているため、設定が必要です
  has_many :stays, foreign_key: :owner_id, dependent: :destroy

  # 3. シッタープロフィール（自分がシッターの場合）
  has_one :sitter_profile, dependent: :destroy

  # 4. メッセージ（今回追加する機能！）
  #    さっき作ったモデルの通り、user_id で紐付けます
  has_many :messages, dependent: :destroy

  # --- (以下はまだ使いませんが、将来のために残しておいてもOKな設定) ---
  # has_many :sitting_stays, class_name: "Stay", foreign_key: :sitter_id, dependent: :nullify
  # has_many :received_reviews, class_name: "Review", foreign_key: "ratee_id", dependent: :nullify
end