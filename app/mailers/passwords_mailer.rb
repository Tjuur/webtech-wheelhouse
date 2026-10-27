class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Wheelhouse — Reset your password"
    )
  end
end