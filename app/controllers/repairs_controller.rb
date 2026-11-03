class RepairsController < ApplicationController
  before_action :set_repair, only: [ :show, :edit, :update, :destroy ]
  before_action :set_repair_for_photo, only: [ :destroy_intake_photo ]

  def index
    authorize Repair

    @repairs = policy_scope(Repair)
      .includes(
        :staff,
        :repair_services,
        { received_by_user: :staff },
        { bike: :customer }
      )
      .with_attached_intake_photos
      .with_rich_text_diagnosis
      .by_promised_date
  end

  def show
    authorize @repair

    @repair_services = @repair.repair_services.sort_by do |repair_service|
      repair_service.service.name
    end
  end

  def new
    @repair = Repair.new(bike_id: params[:bike_id])
    authorize @repair

    set_form_options
    ensure_empty_lines
  end

  def create
    @repair = Repair.new
    authorize @repair

    @repair.assign_attributes(repair_attributes_without_photos)
    @repair.received_by_user = Current.user
    @repair.intake_photos = submitted_photos

    if @repair.save
      redirect_to @repair,
        notice: "Repair ##{@repair.id} was created."
    else
      set_form_options
      ensure_empty_lines
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @repair

    set_form_options
    ensure_empty_lines
  end

  def update
    authorize @repair

    @repair.assign_attributes(repair_attributes_without_photos)

    if submitted_photos.any?
      @repair.intake_photos = @repair.intake_photos.blobs + submitted_photos
    end

    if @repair.save
      redirect_to @repair,
        notice: "Repair ##{@repair.id} was updated."
    else
      set_form_options
      ensure_empty_lines
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @repair

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
    authorize @repair, :destroy_intake_photo?

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
        { received_by_user: :staff },
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
    editable_attributes = policy(@repair).permitted_attributes

    @bikes = if editable_attributes.include?(:bike_id)
      Bike.includes(:customer).by_make_and_model
    else
      Bike.none
    end

    @staff = if editable_attributes.include?(:staff_id)
      Staff.mechanics.by_name
    else
      Staff.none
    end

    @services = if editable_attributes.any? { |attribute|
      attribute.is_a?(Hash) && attribute.key?(:repair_services_attributes)
    }
      Service.by_name
    else
      Service.none
    end
  end

  def ensure_empty_lines
    empty_lines_needed = [ 3 - @repair.repair_services.size, 0 ].max

    empty_lines_needed.times do
      @repair.repair_services.build
    end
  end

  def repair_params
    params.require(:repair).permit(*policy(@repair).permitted_attributes)
  end

  def repair_attributes_without_photos
    repair_params.except(:intake_photos)
  end

  def submitted_photos
    repair_params[:intake_photos].to_a.reject(&:blank?)
  end
end
