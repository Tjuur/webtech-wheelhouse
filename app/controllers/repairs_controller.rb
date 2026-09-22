class RepairsController < ApplicationController
	def index
		@repairs = Repair.includes(bike: :customer).by_promised_date
	end

	def show
		@repair = Repair.includes(
			:staff,
			bike: :customer,
			repair_services: :service
		).find(params[:id])

		@repair_services = @repair.repair_services.by_service_name
	end
end