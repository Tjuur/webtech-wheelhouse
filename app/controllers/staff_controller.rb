class StaffController < ApplicationController
	def index
		@staff = Staff.by_name
	end

	def show
		@staff_member = Staff.includes(repairs: { bike: :customer }).find(params[:id])
		@repairs = @staff_member.repairs.by_promised_date
	end
end