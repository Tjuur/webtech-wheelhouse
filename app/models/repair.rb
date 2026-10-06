class Repair < ApplicationRecord
	MAX_INTAKE_PHOTO_SIZE = 5.megabytes
	ALLOWED_INTAKE_PHOTO_TYPES = %w[image/jpeg image/png].freeze

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

	has_many_attached :intake_photos do |attachable|
		attachable.variant :thumbnail,
			resize_to_fill: [120, 90]

		attachable.variant :display,
			resize_to_limit: [800, 600]
	end

	has_rich_text :diagnosis

	has_many :repair_services, dependent: :destroy
	has_many :services, through: :repair_services, dependent: :destroy

	accepts_nested_attributes_for :repair_services,
		allow_destroy: true,
		reject_if: ->(attributes) {
			attributes["service_id"].blank? && attributes[:service_id].blank?
		}

	validates :status, presence: true
	validates_associated :repair_services

	validate :dates_must_follow_intake
	validate :lifecycle_must_be_consistent
	validate :intake_photos_must_be_valid

	scope :open, -> { where(handed_back_at: nil) }
	scope :overdue, -> { open.where(promised_on: ...Date.current) }
	scope :by_promised_date, -> { order(:promised_on) }

	def overdue?
		handed_back_at.nil? &&
			promised_on.present? &&
			promised_on < Date.current
	end

	def total
		repair_services.sum(:charged_price)
	end

	private

	def intake_photos_must_be_valid
		intake_photos.each do |photo|
			next unless photo.blob

			unless ALLOWED_INTAKE_PHOTO_TYPES.include?(photo.blob.content_type)
				errors.add(
					:intake_photos,
					"#{photo.blob.filename} must be a JPEG or PNG image"
				)
			end

			if photo.blob.byte_size > MAX_INTAKE_PHOTO_SIZE
				errors.add(
					:intake_photos,
					"#{photo.blob.filename} must be 5 MB or smaller"
				)
			end
		end
	end

	def dates_must_follow_intake
		intake_date = created_at&.to_date || Date.current

		if promised_on.present? && promised_on < intake_date
			errors.add(
				:promised_on,
				"cannot be before the repair came in"
			)
		end

		if handed_back_at.present? && handed_back_at.to_date < intake_date
			errors.add(
				:handed_back_at,
				"cannot be before the repair came in"
			)
		end
	end

	def lifecycle_must_be_consistent
		if handed_back_at.present? && !picked_up?
			errors.add(
				:handed_back_at,
				"can only be recorded when the repair has been picked up"
			)
		end

		if (in_progress? || ready? || picked_up?) && approval_status.blank?
			errors.add(
				:approval_status,
				"must be recorded before the repair can move past customer approval"
			)
		end

		if declined? && approval_status.blank?
			errors.add(
				:approval_status,
				"must be recorded when the customer declines the repair"
			)
		end
	end
end