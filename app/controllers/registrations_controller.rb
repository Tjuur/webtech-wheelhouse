class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      WelcomeMailer.welcome(@user).deliver_later
      start_new_session_for(@user)
      redirect_to after_authentication_url, notice: "Your Wheelhouse account has been created."
    else
      @user.password = nil
      @user.password_confirmation = nil
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
