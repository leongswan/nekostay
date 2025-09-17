class Payment < ApplicationRecord
  belongs_to :stay
  enum status: { auth: "auth", captured: "captured", refunded: "refunded" }, _prefix: true
end