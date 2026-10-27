require "test_helper"

class WelcomeMailerTest < ActionMailer::TestCase
  test "welcome email contains the account details" do
    user = User.new(
      email_address: "test@example.com",
      password: "securepassword123"
    )

    mail = WelcomeMailer.welcome(user)

    assert_equal "Welcome to Wheelhouse!", mail.subject
    assert_equal [ "test@example.com" ], mail.to

    assert_match "test@example.com", mail.html_part.body.decoded
    assert_match "test@example.com", mail.text_part.body.decoded

    assert_match "/session/new", mail.html_part.body.decoded
    assert_match "/session/new", mail.text_part.body.decoded
  end
end