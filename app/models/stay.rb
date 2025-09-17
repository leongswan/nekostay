class Stay < ApplicationRecord
  # 関連
  belongs_to :pet,    optional: true
  belongs_to :owner,  class_name: "User"
  belongs_to :sitter, class_name: "User", optional: true

  belongs_to :parent_stay, class_name: "Stay", optional: true
  has_many   :children,
             class_name: "Stay",
             foreign_key: :parent_stay_id,
             dependent: :destroy   # 🔹 子も削除される

  # 文字列enum（DBはstring）
  enum :place,  { owner_home: "owner_home", sitter_home: "sitter_home" },  prefix: true
  enum :status, { draft: "draft", active: "active", completed: "completed", cancelled: "cancelled" }, prefix: true

  # バリデーション（新カラムに合わせる）
  validates :owner,    presence: true
  validates :start_on, presence: true
  validates :end_on,   presence: true
  validate  :end_after_start

  private

  def end_after_start
    return if start_on.blank? || end_on.blank?
    errors.add(:end_on, "must be on or after start_on") if end_on < start_on
  end
end