class Stay < ApplicationRecord
  belongs_to :user
  belongs_to :parent_stay, class_name: "Stay", optional: true
  has_many   :children, class_name: "Stay", foreign_key: :parent_stay_id, dependent: :nullify
  has_many :handoffs, dependent: :destroy
  has_many :checkins, dependent: :destroy

  validates :pet_name, :start_date, :end_date, presence: true
end
