class PasswordsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    email = params[:email_address].to_s.strip.downcase

    if user = User.find_by(email_address: email)
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path,
      notice: "If an account exists with that email address, password reset instructions have been sent."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      redirect_to new_session_path,
        notice: "Your password has been reset. You can now sign in."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path,
      alert: "Password reset link is invalid or has expired."
  end
end