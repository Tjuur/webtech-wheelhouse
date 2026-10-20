class Api::V1::RepairsController < Api::V1::BaseController
  def index
    repairs = Repair
      .includes(bike: :customer, repair_services: :service)
      .by_promised_date

    repairs = filter_by_state(repairs) if params[:state].present?

    render json: repairs.map { |repair| repair_document(repair) }
  end

  def show
    repair = Repair
      .includes(bike: :customer, repair_services: :service)
      .find(params[:id])

    render json: repair_document(repair)
  end

  private

  def filter_by_state(repairs)
    state = params[:state]

    unless Repair.statuses.value?(state)
      valid_states = Repair.statuses.values.join(", ")

      raise Api::V1::BaseController::BadRequest,
        "Invalid state. Valid states: #{valid_states}"
    end

    repairs.where(status: state)
  end

  def repair_document(repair)
    {
      id: repair.id,
      state: repair.status,
      received_on: repair.created_at.to_date,
      promised_on: repair.promised_on,
      handed_back_on: repair.handed_back_at&.to_date,
      bike: {
        brand: repair.bike.make,
        model: repair.bike.model,
        serial_number: repair.bike.serial_number
      },
      customer: {
        name: repair.bike.customer.name
      },
      lines: repair.repair_services.map do |line|
        {
          service: line.service.name,
          charged_price: line.charged_price.to_s
        }
      end,
      total: repair.repair_services.sum(&:charged_price).to_s,
      overdue: repair.overdue?,
      customer_answer: repair.approval_status
    }
  end
end
