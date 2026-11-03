class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Customer
    @customers = policy_scope(Customer).by_name
  end

  def show
    authorize @customer
    @bikes = @customer.bikes.order(:make, :model)
  end

  def new
    @customer = Customer.new
    authorize @customer
  end

  def create
    @customer = Customer.new
    authorize @customer
    @customer.assign_attributes(customer_params)

    if @customer.save
      redirect_to @customer,
        notice: "Customer #{@customer.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @customer
  end

  def update
    authorize @customer

    if @customer.update(customer_params)
      redirect_to @customer,
        notice: "Customer #{@customer.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @customer
    customer_name = @customer.name

    if @customer.destroy
      redirect_to customers_path,
        notice: "Customer #{customer_name} was deleted.",
        status: :see_other
    else
      redirect_to @customer,
        alert: @customer.errors.full_messages.to_sentence,
        status: :see_other
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.expect(customer: [ :name, :phone ])
  end
end
