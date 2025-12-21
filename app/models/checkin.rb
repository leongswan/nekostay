class Checkin < ApplicationRecord
  belongs_to :stay
  # ユーザー（シッター）との紐付けは任意(optional)にしておきます
  belongs_to :user, optional: true

  has_many_attached :images

  # --- ★★★ 今回の追加機能（ここが一番大事！） ★★★ ---
  
  # ごはんの状況（DBには 0, 1, 2... の数字で保存されます）
  enum food: { no_food: 0, little_left: 1, half_eaten: 2, finished: 3 }, _prefix: true

  # ご機嫌の状況
  enum mood: { normal: 0, happy: 1, cuddly: 2, hiding: 3, angry: 4 }, _prefix: true
  
  # --------------------------------------------------

  # バリデーション
  validates :checked_at, presence: true
  
  # ※もし weight カラムがDBにない場合はエラーになるので、一旦コメントアウトしておきます
  # validates :weight, numericality: { greater_than: 0 }, allow_nil: true

  # スコープ（便利なので残しておきます）
  scope :recent,         -> { order(checked_at: :desc) }
  scope :on_day,         ->(date) { where(checked_at: date.all_day) }
  scope :for_stay,       ->(stay_id) { where(stay_id: stay_id) } # Rubyのバージョンによっては stay_id: stay_id と書くほうが安全です
end
