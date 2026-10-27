class WelcomeMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first || User.new(
      email_address: "preview@wheelhouse.cl",
      password: "previewpassword123"
    )

    WelcomeMailer.welcome(user)
  end
end