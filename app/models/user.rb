class User < ApplicationRecord
  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 権限設定（そのまま残します）
  enum role: { owner: 0, sitter: 1, admin: 2 }, _prefix: true

  # プロフィール画像
  has_one_attached :image

  # --- 関連付け（リレーション） ---

  # 1. ペット
  has_many :pets, dependent: :destroy

  # 2. 予約（自分が飼い主として作成したもの）
  has_many :stays, foreign_key: :owner_id, dependent: :destroy

  # 3. シッターとしてのお仕事（★今回追加：マイページでお仕事履歴を表示するため）
  #    ※ 元のコードではコメントアウトされていましたが、今回使います！名前を sitter_stays にしました。
  has_many :sitter_stays, class_name: 'Stay', foreign_key: :sitter_id

  # 4. シッタープロフィール（そのまま残します）
  has_one :sitter_profile, dependent: :destroy

  # 5. メッセージ（そのまま残します）
  has_many :messages, dependent: :destroy

  # --- バリデーション（★今回追加） ---
  validates :name, presence: true # 名前は必須
  validates :introduction, length: { maximum: 500 } # 自己紹介は500文字まで
end