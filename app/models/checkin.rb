class Checkin < ApplicationRecord
  belongs_to :stay
  # ユーザー（シッター）との紐付けは任意(optional)にしておきます
  belongs_to :user, optional: true

  has_many_attached :images

  # --- ★★★ エラー対策：一時的に無効化 ★★★ ---
  # DBに food / mood カラムがまだ存在しないため、
  # 以下のenum定義を有効にすると本番環境で500エラーになります。
  # カラム追加のマイグレーションを行うまではコメントアウトしておきます。
  
  enum food: { no_food: 0, little_left: 1, half_eaten: 2, finished: 3 }, _prefix: true
  enum mood: { normal: 0, happy: 1, cuddly: 2, hiding: 3, angry: 4 }, _prefix: true
  
  # --------------------------------------------------

  # バリデーション
  validates :checked_at, presence: true
  
  # ※ weight カラムなどもDBにない場合はエラーになるので、コメントアウトのままでOKです
  # validates :weight, numericality: { greater_than: 0 }, allow_nil: true

  # スコープ
  scope :recent,         -> { order(checked_at: :desc) }
  scope :on_day,         ->(date) { where(checked_at: date.all_day) }
  scope :for_stay,       ->(stay_id) { where(stay_id: stay_id) }
end
