class Checkin < ApplicationRecord
  belongs_to :stay

  # ↓↓↓ ここを修正！「optional: true」をつけるのが最大のポイントです ↓↓↓
  belongs_to :user, optional: true
  # ------------------------------------------------------------------

  # ↓↓↓ この行を追加（複数枚の写真を許可します） ↓↓↓
  has_many_attached :images
  # ---------------------------------------------

  # バリデーション
  validates :checked_at, presence: true
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true

  # JSON カラムは Hash or Array を期待
  validate :json_shapes

  # スコープ
  scope :recent,         -> { order(checked_at: :desc) }
  scope :on_day,         ->(date) { where(checked_at: date.all_day) }
  scope :for_stay,       ->(stay_id) { where(stay_id:) }
  scope :between,        ->(from, to) { where(checked_at: from..to) }

  private

  def json_shapes
    %i[meal litter meds].each do |field|
      val = self[field]
      next if val.nil?
      unless val.is_a?(Hash) || val.is_a?(Array)
        errors.add(field, "must be a JSON object or array")
      end
    end
  end
end
