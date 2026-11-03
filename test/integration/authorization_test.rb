require "test_helper"

class AuthorizationIntegrationTest < ActionDispatch::IntegrationTest
  PASSWORD = "testpassword123"

  setup do
    @owner = create_user("owner", :owner)
    @counter = create_user("counter", :counter)

    @mechanic_staff = Staff.create!(
      name: "Integration Mechanic A",
      role: "mechanic"
    )

    @other_staff = Staff.create!(
      name: "Integration Mechanic B",
      role: "mechanic"
    )

    @mechanic = create_user(
      "mechanic",
      :mechanic,
      @mechanic_staff
    )

    @other_mechanic = create_user(
      "other_mechanic",
      :mechanic,
      @other_staff
    )

    @customer = Customer.create!(
      name: "Integration Customer",
      phone: "123456789"
    )

    @bike = Bike.create!(
      customer: @customer,
      make: "Trek",
      model: "Marlin",
      colour: "Black",
      serial_number: "INTEGRATION-001"
    )

    @assigned_repair = Repair.create!(
      bike: @bike,
      staff: @mechanic_staff,
      status: :received
    )

    @foreign_repair = Repair.create!(
      bike: @bike,
      staff: @other_staff,
      status: :received
    )

    @unassigned_repair = Repair.create!(
      bike: @bike,
      staff: nil,
      status: :received
    )

    @service = Service.create!(
      name: "Integration Brake Adjustment",
      current_price: 15000
    )
  end

  # ============================================================
  # AUTHENTICATION
  # ============================================================

  test "visitor is redirected from private resources" do
    get customers_path
    assert_redirected_to new_session_path

    get bikes_path
    assert_redirected_to new_session_path

    get repairs_path
    assert_redirected_to new_session_path

    get staff_index_path
    assert_redirected_to new_session_path
  end

  test "visitor can access public services" do
    get services_path
    assert_response :success

    get service_path(@service)
    assert_response :success
  end

  # ============================================================
  # OWNER
  # ============================================================

  test "owner can access all resource indexes" do
    sign_in_as(@owner)

    get customers_path
    assert_response :success

    get bikes_path
    assert_response :success

    get repairs_path
    assert_response :success

    get services_path
    assert_response :success

    get staff_index_path
    assert_response :success
  end

  test "owner can edit assigned and foreign repairs" do
    sign_in_as(@owner)

    get edit_repair_path(@assigned_repair)
    assert_response :success

    get edit_repair_path(@foreign_repair)
    assert_response :success
  end

  # ============================================================
  # COUNTER
  # ============================================================

  test "counter can access customers and bikes" do
    sign_in_as(@counter)

    get customers_path
    assert_response :success

    get bikes_path
    assert_response :success
  end

  test "counter cannot delete customers" do
    sign_in_as(@counter)

    assert_no_difference "Customer.count" do
      delete customer_path(@customer)
    end

    assert_response :forbidden
    assert Customer.exists?(@customer.id)
  end

  test "counter cannot delete bikes" do
    sign_in_as(@counter)

    assert_no_difference "Bike.count" do
      delete bike_path(@bike)
    end

    assert_response :forbidden
    assert Bike.exists?(@bike.id)
  end

  test "counter cannot create services" do
    sign_in_as(@counter)

    assert_no_difference "Service.count" do
      post services_path, params: {
        service: {
          name: "Forbidden Service",
          current_price: 1000
        }
      }
    end

    assert_response :forbidden
  end

  test "counter cannot edit staff" do
    sign_in_as(@counter)

    get edit_staff_path(@mechanic_staff)
    assert_response :forbidden
  end

  test "counter cannot delete repairs" do
    sign_in_as(@counter)

    assert_no_difference "Repair.count" do
      delete repair_path(@assigned_repair)
    end

    assert_response :forbidden
    assert Repair.exists?(@assigned_repair.id)
  end

  # ============================================================
  # MECHANIC
  # ============================================================

  test "mechanic cannot access customers" do
    sign_in_as(@mechanic)

    get customers_path
    assert_response :forbidden

    get customer_path(@customer)
    assert_response :forbidden
  end

  test "mechanic cannot access bikes" do
    sign_in_as(@mechanic)

    get bikes_path
    assert_response :forbidden

    get bike_path(@bike)
    assert_response :forbidden
  end

  test "mechanic can view assigned repair" do
    sign_in_as(@mechanic)

    get repair_path(@assigned_repair)
    assert_response :success
  end

  test "mechanic cannot view foreign repair" do
    sign_in_as(@mechanic)

    get repair_path(@foreign_repair)
    assert_response :forbidden
  end

  test "mechanic cannot edit foreign repair" do
    sign_in_as(@mechanic)

    get edit_repair_path(@foreign_repair)
    assert_response :forbidden
  end

  test "mechanic cannot update foreign repair" do
    sign_in_as(@mechanic)

    original_status = @foreign_repair.status

    patch repair_path(@foreign_repair), params: {
      repair: {
        status: "ready"
      }
    }

    assert_response :forbidden
    assert_equal original_status, @foreign_repair.reload.status
  end

  test "mechanic cannot create repairs" do
    sign_in_as(@mechanic)

    assert_no_difference "Repair.count" do
      post repairs_path, params: {
        repair: {
          bike_id: @bike.id,
          status: "received"
        }
      }
    end

    assert_response :forbidden
  end

  test "mechanic cannot view unassigned repair" do
    sign_in_as(@mechanic)

    get repair_path(@unassigned_repair)
    assert_response :forbidden
  end

  # ============================================================
  # PARAMETER INJECTION
  # ============================================================

  test "mechanic cannot change assigned staff through parameters" do
    sign_in_as(@mechanic)

    original_staff_id = @assigned_repair.staff_id

    patch repair_path(@assigned_repair), params: {
      repair: {
        status: "assessment",
        staff_id: @other_staff.id
      }
    }

    assert_response :redirect

    assert_equal original_staff_id,
      @assigned_repair.reload.staff_id

    assert_equal "assessment",
      @assigned_repair.status
  end

  test "mechanic cannot change handed back date through parameters" do
    sign_in_as(@mechanic)

    patch repair_path(@assigned_repair), params: {
      repair: {
        status: "assessment",
        handed_back_at: Time.current
      }
    }

    assert_response :redirect
    assert_nil @assigned_repair.reload.handed_back_at
  end

  # ============================================================
  # REPAIR SCOPES
  # ============================================================

  test "mechanic repair index only shows assigned repairs" do
    sign_in_as(@mechanic)

    get repairs_path

    assert_response :success

    assert_select "a[href=?]",
      repair_path(@assigned_repair)

    assert_select "a[href=?]",
      repair_path(@foreign_repair),
      count: 0

    assert_select "a[href=?]",
      repair_path(@unassigned_repair),
      count: 0
  end

  test "owner repair index shows all repairs" do
    sign_in_as(@owner)

    get repairs_path

    assert_response :success

    assert_select "a[href=?]",
      repair_path(@assigned_repair)

    assert_select "a[href=?]",
      repair_path(@foreign_repair)

    assert_select "a[href=?]",
      repair_path(@unassigned_repair)
  end

  # ============================================================
  # HANDED-BACK REPAIRS
  # ============================================================

  test "counter cannot edit handed back repair" do
    sign_in_as(@counter)

    @assigned_repair.update!(
      status: :picked_up,
      approval_status: "approved",
      handed_back_at: Time.current
    )

    get edit_repair_path(@assigned_repair)

    assert_response :forbidden
  end

  test "mechanic cannot edit handed back repair" do
    sign_in_as(@mechanic)

    @assigned_repair.update!(
      status: :picked_up,
      approval_status: "approved",
      handed_back_at: Time.current
    )

    get edit_repair_path(@assigned_repair)

    assert_response :forbidden
  end

  test "owner can edit handed back repair" do
    sign_in_as(@owner)

    @assigned_repair.update!(
      status: :picked_up,
      approval_status: "approved",
      handed_back_at: Time.current
    )

    get edit_repair_path(@assigned_repair)

    assert_response :success
  end

  private

  def create_user(name, role, staff = nil)
    User.create!(
      email_address: "#{name}@integration-test.example",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      role: role,
      staff: staff
    )
  end

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: PASSWORD
    }

    assert_response :redirect
  end
end
