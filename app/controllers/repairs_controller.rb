class RepairsController < ApplicationController
	before_action :set_repair, only: [:show, :edit, :update, :destroy]
	before_action :set_repair_for_photo, only: [:destroy_intake_photo]
	before_action :set_form_options, only: [:new, :create, :edit, :update]

	def index
		@repairs = Repair
			.includes(bike: :customer)
			.with_attached_intake_photos
			.with_rich_text_diagnosis
			.by_promised_date
	end

	def show
		@repair_services = @repair.repair_services.sort_by do |repair_service|
			repair_service.service.name
		end
	end

	def new
		@repair = Repair.new(bike_id: params[:bike_id])

		3.times do
			@repair.repair_services.build
		end
	end

	def create
		@repair = Repair.new(repair_attributes_without_photos)
		@repair.intake_photos = submitted_photos

		if @repair.save
			redirect_to @repair,
				notice: "Repair ##{@repair.id} was created."
		else
			ensure_empty_lines
			render :new, status: :unprocessable_entity
		end
	end

	def edit
		ensure_empty_lines
	end

	def update
		@repair.assign_attributes(repair_attributes_without_photos)

		if submitted_photos.any?
			@repair.intake_photos = @repair.intake_photos.blobs + submitted_photos
		end

		if @repair.save
			redirect_to @repair,
				notice: "Repair ##{@repair.id} was updated."
		else
			ensure_empty_lines
			render :edit, status: :unprocessable_entity
		end
	end

	def destroy
		repair_id = @repair.id

		if @repair.destroy
			redirect_to repairs_path,
				notice: "Repair ##{repair_id} was deleted.",
				status: :see_other
		else
			redirect_to @repair,
				alert: @repair.errors.full_messages.to_sentence,
				status: :see_other
		end
	end

	def destroy_intake_photo
		photo = @repair.intake_photos.attachments.find(params[:attachment_id])
		photo.purge

		redirect_to @repair,
			notice: "Intake photo was removed.",
			status: :see_other
	end

	private

	def set_repair
		@repair = Repair
			.includes(
				:staff,
				{ bike: :customer },
				{ repair_services: :service }
			)
			.with_attached_intake_photos
			.with_rich_text_diagnosis
			.find(params[:id])
	end

	def set_repair_for_photo
		@repair = Repair.find(params[:repair_id])
	end

	def set_form_options
		@bikes = Bike.includes(:customer).by_make_and_model
		@staff = Staff.mechanics.by_name
		@services = Service.by_name
	end

	def ensure_empty_lines
		empty_lines_needed = [3 - @repair.repair_services.size, 0].max

		empty_lines_needed.times do
			@repair.repair_services.build
		end
	end

	def repair_params
		params.expect(
			repair: [
				:bike_id,
				:staff_id,
				:status,
				:approval_status,
				:promised_on,
				:quoted_at,
				:handed_back_at,
				:diagnosis,
				intake_photos: [],
				repair_services_attributes: [[
					:id,
					:service_id,
					:charged_price,
					:_destroy
				]]
			]
		)
	end

	def repair_attributes_without_photos
		repair_params.except(:intake_photos)
	end

	def submitted_photos
		repair_params[:intake_photos].to_a.reject(&:blank?)
	end
end