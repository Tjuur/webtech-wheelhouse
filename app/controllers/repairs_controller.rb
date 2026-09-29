class RepairsController < ApplicationController
	before_action :set_repair, only: [:show, :edit, :update, :destroy]
	before_action :set_form_options, only: [:new, :create, :edit, :update]

	def index
		@repairs = Repair.includes(bike: :customer).by_promised_date
	end

	def show
		@repair_services = @repair.repair_services
			.includes(:service)
			.by_service_name
	end

	def new
		@repair = Repair.new(bike_id: params[:bike_id])

		3.times do
			@repair.repair_services.build
		end
	end

	def create
		@repair = Repair.new(repair_params)

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
		if @repair.update(repair_params)
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

	private

	def set_repair
		@repair = Repair.includes(
			:staff,
			bike: :customer
		).find(params[:id])
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
				repair_services_attributes: [[
					:id,
					:service_id,
					:charged_price,
					:_destroy
				]]
			]
		)
	end
end