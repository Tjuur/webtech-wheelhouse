class Staff < ApplicationRecord
  has_many :repairs, dependent: :restrict_with_error

  has_one :user, dependent: :restrict_with_error

  validates :name, presence: true
  validates :role, presence: true

  scope :by_name, -> { order(:name) }
  scope :mechanics, -> { where(role: "mechanic") }
end