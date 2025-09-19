class Handoff < ApplicationRecord
  belongs_to :from_stay, class_name: "Stay"
  belongs_to :to_stay,   class_name: "Stay"

  validates :from_stay, :to_stay, presence: true
  validate  :chronology

  scope :completed,   -> { where.not(completed_at: nil) }
  scope :scheduled,   -> { where(completed_at: nil) }
  scope :for_owner,   ->(user) { joins(:from_stay).where(stays: { owner_id: user.id }) }

  def complete!(at: Time.current)
    update!(completed_at: at)
  end

  private

  def chronology
    return if from_stay.blank? || to_stay.blank?
    if to_stay.start_on < from_stay.start_on
      errors.add(:to_stay, "must start on or after from_stay")
    end
  end
end
