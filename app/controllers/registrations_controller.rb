require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registration page is publicly accessible" do
    get new_registration_path

    assert_response :success
  end

  test "valid registration creates a user" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :redirect

    user = User.find_by!(email_address: "newuser@example.com")
    assert user.counter?
    assert_nil user.staff
  end

  test "invalid registration does not create a user" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "invalid@example.com",
          password: "short",
          password_confirmation: "short"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "registration rejects mismatched passwords" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "mismatch@example.com",
          password: "Password123!",
          password_confirmation: "Different123!"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "registration cannot assign privileged roles" do
    assert_raises(ActionController::UnpermittedParameters) do
      post registration_path, params: {
        user: {
          email_address: "attacker@example.com",
          password: "Password123!",
          password_confirmation: "Password123!",
          role: "owner"
        }
      }
    end
  end
end