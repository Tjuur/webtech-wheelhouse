class ServicesController < ApplicationController
	def index
		@services = Service.by_name
	end

	def show
		@service = Service.includes(
			repair_services: { repair: :bike }
		).find(params[:id])

		@repair_services = @service.repair_services.by_service_name
	end
end