require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(
      email_address: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    assert user.valid?
  end

  test "email is required" do
    user = User.new(password: "Password123!")

    assert_not user.valid?
    assert user.errors[:email_address].any?
  end

  test "email is normalized" do
    user = User.new(
      email_address: "  TEST@EXAMPLE.COM  ",
      password: "Password123!"
    )

    assert_equal "test@example.com", user.email_address
  end

  test "email must be unique regardless of case" do
    User.create!(
      email_address: "unique@example.com",
      password: "Password123!"
    )

    duplicate = User.new(
      email_address: "UNIQUE@example.com",
      password: "Password123!"
    )

    assert_not duplicate.valid?
    assert duplicate.errors[:email_address].any?
  end

  test "password must have at least ten characters" do
    user = User.new(
      email_address: "short@example.com",
      password: "short"
    )

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "password confirmation must match" do
    user = User.new(
      email_address: "mismatch@example.com",
      password: "Password123!",
      password_confirmation: "Different123!"
    )

    assert_not user.valid?
    assert user.errors[:password_confirmation].any?
  end

  test "new users receive counter role by default" do
    user = User.new(
      email_address: "role@example.com",
      password: "Password123!"
    )

    assert user.counter?
  end

  test "staff association is optional" do
    user = User.new(
      email_address: "nostaff@example.com",
      password: "Password123!"
    )

    assert user.valid?
    assert_nil user.staff
  end
end
