class RepairService < ApplicationRecord
  belongs_to :repair
  belongs_to :service

  validates :charged_price, presence: true, numericality: { greater_than: 0 }

  scope :by_service_name, -> { joins(:service).order("services.name") }
  scope :newest_first, -> { joins(:repair).order("repairs.created_at DESC") }
end