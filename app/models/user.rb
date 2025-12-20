class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { owner: 0, sitter: 1, admin: 2 }, _prefix: true

  # ↓ ここに追加
  has_one_attached :avatar
  # ----------------
  # ↓↓↓ この1行を追加してください！ ↓↓↓
  has_many :stays
  # ------------------------------------

  # --- 修正 ---

  # 1. 曖昧な :stays を削除
  # has_many :stays, dependent: :destroy # <- 削除

  # 2. ブループリントとエラーに基づき、必要な関連付けを追加
  has_many :pets, dependent: :destroy
  has_one :sitter_profile, dependent: :destroy
  
  # has_many :owned_stays (定義済み)
  has_many :owned_stays,   class_name: "Stay", foreign_key: :owner_id, dependent: :nullify
  
  # has_many :sitting_stays (定義済み - "sitted_stays" が一般的かもしれません)
  has_many :sitting_stays, class_name: "Stay", foreign_key: :sitter_id, dependent: :nullify
  
  # 3. README に基づき、他の関連付けも追加
  belongs_to :address, optional: true
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :nullify
  has_many :given_reviews, class_name: "Review", foreign_key: "rater_id", dependent: :nullify
  has_many :received_reviews, class_name: "Review", foreign_key: "ratee_id", dependent: :nullify
end