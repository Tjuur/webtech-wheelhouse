# app/models/bike.rb
class Bike < ApplicationRecord
    belongs_to :customer

    has_many :repairs, dependent: :restrict_with_error

    validates :make, presence: true
    validates :model, presence: true
    validates :colour, presence: true
    validates :serial_number, presence: true, uniqueness: true

    scope :by_make_and_model, -> { order(:make, :model, :serial_number) }

    before_validation :normalize_serial_number

    private

    def normalize_serial_number
        self.serial_number = serial_number.strip.upcase if serial_number.present?
    end
end