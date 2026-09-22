class Repair < ApplicationRecord
	enum :status, {
		received: "Received",
		assessment: "Assessment",
		awaiting_approval: "Awaiting Approval",
		in_progress: "In Progress",
		ready: "Ready",
		declined: "Declined",
		picked_up: "Picked Up"
	}

	belongs_to :bike
	belongs_to :staff, optional: true

	has_many :repair_services, dependent: :destroy
	has_many :services, through: :repair_services, dependent: :destroy

	validates :status, presence: true

	validate :dates_must_follow_intake
  validate :lifecycle_must_be_consistent

  scope :open, -> { where(handed_back_at: nil) }
  scope :overdue, -> { open.where(promised_on: ...Date.current) }
  scope :by_promised_date, -> { order(:promised_on) }

  def overdue?
    handed_back_at.nil? && promised_on.present? && promised_on < Date.current
  end

  def total
    repair_services.sum(:charged_price)
  end

  private

	def dates_must_follow_intake
		return if created_at.blank?

		if promised_on.present? && promised_on < created_at.to_date
			errors.add(:promised_on, "cannot be before the repair came in")
		end

		if handed_back_at.present? && handed_back_at.to_date < created_at.to_date
			errors.add(:handed_back_at, "cannot be before the repair came in")
		end
	end

  def lifecycle_must_be_consistent
    if handed_back_at.present? && !picked_up?
      errors.add(:handed_back_at, "can only be recorded when the repair has been picked up")
    end

    if (in_progress? || ready? || picked_up?) && approval_status.blank?
      errors.add(:approval_status, "must be recorded before the repair can move past customer approval")
    end

    if declined? && approval_status.blank?
      errors.add(:approval_status, "must be recorded when the customer declines the repair")
    end
  end
end