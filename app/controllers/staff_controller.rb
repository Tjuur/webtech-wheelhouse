class StaffController < ApplicationController
  def index
    @staff = Staff.order(:name)
  end

  def show
    @staff_member = Staff.find(params[:id])
  end
end