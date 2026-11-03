class ServicesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_service, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Service
    @services = policy_scope(Service).by_name
  end

  def show
    authorize @service

    @repair_services = if policy(@service).view_repair_history?
      @service.repair_services
        .joins(:repair)
        .merge(policy_scope(Repair))
        .includes(repair: { bike: :customer })
        .newest_first
    else
      RepairService.none
    end
  end

  def new
    @service = Service.new
    authorize @service
  end

  def create
    @service = Service.new
    authorize @service
    @service.assign_attributes(service_params)

    if @service.save
      redirect_to @service,
        notice: "Service #{@service.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @service
  end

  def update
    authorize @service

    if @service.update(service_params)
      redirect_to @service,
        notice: "Service #{@service.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @service
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
    params.expect(service: [ :name, :current_price ])
  end
end
