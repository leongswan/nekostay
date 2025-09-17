class Vet < ApplicationRecord
  belongs_to :pet
  belongs_to :address
end