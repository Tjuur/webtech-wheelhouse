class Api::V1::ServicesController < Api::V1::BaseController
  skip_before_action :authenticate_api!, only: %i[index show]

  def index
    services = Service.by_name.includes(:repair_services)

    render json: services.map { |service| service_document(service) }
  end

  def show
    service = Service.includes(:repair_services).find(params[:id])

    render json: service_document(service)
  end

  def create
    attributes = service_params

    if attributes.empty?
      raise Api::V1::BaseController::BadRequest,
        "Service attributes are required"
    end

    service = Service.new(attributes)

    if service.save
      render json: service_document(service),
        status: :created,
        location: api_v1_service_url(service)
    else
      render_error(service.errors.full_messages, :unprocessable_entity)
    end
  end

  private

  def service_params
    params.expect(service: %i[name current_price])
  end

  def service_document(service)
    {
      id: service.id,
      name: service.name,
      price: service.current_price.to_s,
      repair_count: service.repair_services.size
    }
  end
end
