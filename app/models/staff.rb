# app/models/staff.rb
class Staff < ApplicationRecord

    has_many :repairs, dependent: :restrict_with_error

    validates :name, presence: true
    validates :role, presence: true

    scope :by_name, -> { order(:name)}
end