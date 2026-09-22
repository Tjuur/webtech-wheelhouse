class BikesController < ApplicationController
	def index
		@bikes = Bike.includes(:customer).by_make_and_model
	end

	def show
		@bike = Bike.includes(repairs: { bike: :customer }).find(params[:id])
		@repairs = @bike.repairs.by_promised_date
	end
end