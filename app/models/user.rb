class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { owner: 0, sitter: 1, admin: 2 }, _prefix: true

  has_many :stays, dependent: :destroy
  has_many :owned_stays,  class_name: "Stay", foreign_key: :owner_id, dependent: :nullify
  has_many :sitting_stays, class_name: "Stay", foreign_key: :sitter_id
end
