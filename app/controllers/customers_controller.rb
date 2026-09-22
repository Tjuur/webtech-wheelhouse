class CustomersController < ApplicationController
  def index
    @customers = Customer.by_name
  end

  def show
    @customer = Customer.includes(bikes: :customer).find(params[:id])
    @bikes = @customer.bikes.by_make_and_model
  end
end