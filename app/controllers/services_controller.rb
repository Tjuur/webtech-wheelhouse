class ServicesController < ApplicationController
	before_action :set_service, only: [:show, :edit, :update, :destroy]

	def index
		@services = Service.by_name
	end

	def show
		@repair_services = @service.repair_services
			.includes(repair: :bike)
			.newest_first
	end

	def new
		@service = Service.new
	end

	def create
		@service = Service.new(service_params)

		if @service.save
			redirect_to @service,
				notice: "Service #{@service.name} was created."
		else
			render :new, status: :unprocessable_entity
		end
	end

	def edit
	end

	def update
		if @service.update(service_params)
			redirect_to @service,
				notice: "Service #{@service.name} was updated."
		else
			render :edit, status: :unprocessable_entity
		end
	end

	def destroy
		service_name = @service.name

		if @service.destroy
			redirect_to services_path,
				notice: "Service #{service_name} was deleted.",
				status: :see_other
		else
			redirect_to @service,
				alert: @service.errors.full_messages.to_sentence,
				status: :see_other
		end
	end

	private

	def set_service
		@service = Service.find(params[:id])
	end

	def service_params
		params.expect(service: [:name, :current_price])
	end
end