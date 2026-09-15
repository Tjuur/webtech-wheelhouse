class RepairsController < ApplicationController
  def index
    @repairs = Repair.order(:promised_on)
  end

  def show
    @repair = Repair.find(params[:id])
  end
end