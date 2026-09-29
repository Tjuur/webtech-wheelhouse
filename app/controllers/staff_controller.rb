class StaffController < ApplicationController
	before_action :set_staff_member, only: [:show, :edit, :update, :destroy]

	def index
		@staff = Staff.by_name
	end

	def show
		@repairs = @staff_member.repairs
			.includes(bike: :customer)
			.by_promised_date
	end

	def new
		@staff_member = Staff.new
	end

	def create
		@staff_member = Staff.new(staff_params)

		if @staff_member.save
			redirect_to staff_path(@staff_member),
				notice: "Staff member #{@staff_member.name} was created."
		else
			render :new, status: :unprocessable_entity
		end
	end

	def edit
	end

	def update
		if @staff_member.update(staff_params)
			redirect_to staff_path(@staff_member),
				notice: "Staff member #{@staff_member.name} was updated."
		else
			render :edit, status: :unprocessable_entity
		end
	end

	def destroy
		staff_name = @staff_member.name

		if @staff_member.destroy
			redirect_to staff_index_path,
				notice: "Staff member #{staff_name} was deleted.",
				status: :see_other
		else
			redirect_to staff_path(@staff_member),
				alert: @staff_member.errors.full_messages.to_sentence,
				status: :see_other
		end
	end

	private

	def set_staff_member
		@staff_member = Staff.find(params[:id])
	end

	def staff_params
		params.expect(staff: [:name, :role])
	end
end