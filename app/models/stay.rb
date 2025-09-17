class Stay < ApplicationRecord
  belongs_to :user
  has_many :handoffs, dependent: :destroy
  has_many :checkins, dependent: :destroy

  validates :pet_name, :start_date, :end_date, presence: true
end
