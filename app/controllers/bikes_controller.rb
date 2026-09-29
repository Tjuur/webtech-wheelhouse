class BikesController < ApplicationController
	before_action :set_bike, only: [:show, :edit, :update, :destroy]
	before_action :set_customers, only: [:new, :create, :edit, :update]

	def index
		@bikes = Bike.includes(:customer).by_make_and_model
	end

	def show
		@repairs = @bike.repairs.includes(bike: :customer).by_promised_date
	end

	def new
		@bike = Bike.new(customer_id: params[:customer_id])
	end

	def create
		@bike = Bike.new(bike_params)

		if @bike.save
			redirect_to @bike,
				notice: "Bike #{@bike.serial_number} was created."
		else
			render :new, status: :unprocessable_entity
		end
	end

	def edit
	end

	def update
		if @bike.update(bike_params)
			redirect_to @bike,
				notice: "Bike #{@bike.serial_number} was updated."
		else
			render :edit, status: :unprocessable_entity
		end
	end

	def destroy
		serial_number = @bike.serial_number

		if @bike.destroy
			redirect_to bikes_path,
				notice: "Bike #{serial_number} was deleted.",
				status: :see_other
		else
			redirect_to @bike,
				alert: @bike.errors.full_messages.to_sentence,
				status: :see_other
		end
	end

	private

	def set_bike
		@bike = Bike.includes(:customer).find(params[:id])
	end

	def set_customers
		@customers = Customer.by_name
	end

	def bike_params
		params.expect(
			bike: [:customer_id, :make, :model, :colour, :serial_number]
		)
	end
end