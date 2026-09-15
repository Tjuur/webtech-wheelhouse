class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :staff, optional: true

  has_many :repair_services
end