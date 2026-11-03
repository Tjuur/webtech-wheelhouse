require "test_helper"

class AuthorizationTest < ActiveSupport::TestCase
  setup do
    # Users
    @owner = User.new(role: :owner)
    @counter = User.new(role: :counter)

    # Staff must be persisted because RepairPolicy compares staff_id
    @mechanic_staff = Staff.create!(
      name: "Mechanic A",
      role: "mechanic"
    )

    @other_staff = Staff.create!(
      name: "Mechanic B",
      role: "mechanic"
    )

    @mechanic = User.new(
      role: :mechanic,
      staff: @mechanic_staff
    )

    @other_mechanic = User.new(
      role: :mechanic,
      staff: @other_staff
    )

    # Records used for authorization checks
    @customer = Customer.new
    @bike = Bike.new

    @assigned_repair = Repair.new(
      staff: @mechanic_staff,
      status: :received
    )

    @foreign_repair = Repair.new(
      staff: @other_staff,
      status: :received
    )

    @handed_back_repair = Repair.new(
      staff: @mechanic_staff,
      status: :picked_up,
      handed_back_at: Time.current
    )
  end

  # ============================================================
  # CUSTOMER POLICY
  # ============================================================

  test "owner has full customer permissions" do
    policy = CustomerPolicy.new(@owner, @customer)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "counter can manage customers but cannot delete" do
    policy = CustomerPolicy.new(@counter, @customer)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert_not policy.destroy?
  end

  test "mechanic cannot access customers" do
    policy = CustomerPolicy.new(@mechanic, @customer)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  # ============================================================
  # BIKE POLICY
  # ============================================================

  test "bike permissions follow customer permissions" do
    owner_policy = BikePolicy.new(@owner, @bike)
    counter_policy = BikePolicy.new(@counter, @bike)
    mechanic_policy = BikePolicy.new(@mechanic, @bike)

    assert owner_policy.destroy?
    assert counter_policy.update?
    assert_not counter_policy.destroy?
    assert_not mechanic_policy.show?
  end

  # ============================================================
  # SERVICE POLICY
  # ============================================================

  test "only owner can modify services" do
    service = Service.new

    owner_policy = ServicePolicy.new(@owner, service)
    counter_policy = ServicePolicy.new(@counter, service)
    mechanic_policy = ServicePolicy.new(@mechanic, service)

    assert owner_policy.create?
    assert owner_policy.update?
    assert owner_policy.destroy?

    assert_not counter_policy.create?
    assert_not mechanic_policy.update?
    assert_not mechanic_policy.destroy?
  end

  # ============================================================
  # STAFF POLICY
  # ============================================================

  test "only owner can modify staff" do
    owner_policy = StaffPolicy.new(@owner, @mechanic_staff)
    counter_policy = StaffPolicy.new(@counter, @mechanic_staff)
    mechanic_policy = StaffPolicy.new(@mechanic, @mechanic_staff)

    assert owner_policy.create?
    assert owner_policy.update?
    assert owner_policy.destroy?

    assert_not counter_policy.create?
    assert_not mechanic_policy.update?
    assert_not mechanic_policy.destroy?
  end

  # ============================================================
  # REPAIR POLICY
  # ============================================================

  test "owner can manage all repairs" do
    policy = RepairPolicy.new(@owner, @foreign_repair)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "counter can create and edit repairs but cannot delete" do
    policy = RepairPolicy.new(@counter, @foreign_repair)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert_not policy.destroy?
  end

  test "mechanic can access assigned repair" do
    policy = RepairPolicy.new(@mechanic, @assigned_repair)

    assert policy.index?
    assert policy.show?
    assert policy.update?

    assert_not policy.create?
    assert_not policy.destroy?
  end

  test "mechanic cannot access another mechanics repair" do
    policy = RepairPolicy.new(@mechanic, @foreign_repair)

    assert_not policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "handed back repairs cannot be edited by counter or mechanic" do
    counter_policy = RepairPolicy.new(
      @counter,
      @handed_back_repair
    )

    mechanic_policy = RepairPolicy.new(
      @mechanic,
      @handed_back_repair
    )

    owner_policy = RepairPolicy.new(
      @owner,
      @handed_back_repair
    )

    assert_not counter_policy.update?
    assert_not mechanic_policy.update?
    assert owner_policy.update?
  end

  test "mechanic cannot modify restricted repair attributes" do
    attributes = RepairPolicy.new(
      @mechanic,
      @assigned_repair
    ).permitted_attributes

    # Allowed attributes
    assert_includes attributes, :status
    assert_includes attributes, :diagnosis
    assert_includes attributes, { intake_photos: [] }

    # Forbidden attributes
    assert_not_includes attributes, :staff_id
    assert_not_includes attributes, :bike_id
    assert_not_includes attributes, :handed_back_at
    assert_not_includes attributes, :approval_status
    assert_not_includes attributes, :promised_on
    assert_not_includes attributes, :quoted_at

    # Mechanics cannot modify service pricing
    assert_not attributes.any? { |attribute|
      attribute.is_a?(Hash) &&
        attribute.key?(:repair_services_attributes)
    }
  end

  test "mechanic cannot remove intake photos" do
    policy = RepairPolicy.new(@mechanic, @assigned_repair)

    assert_not policy.destroy_intake_photo?
  end

  test "counter can remove photos before hand back" do
    policy = RepairPolicy.new(@counter, @assigned_repair)

    assert policy.destroy_intake_photo?
  end

  test "counter cannot remove photos after hand back" do
    policy = RepairPolicy.new(@counter, @handed_back_repair)

    assert_not policy.destroy_intake_photo?
  end

  test "owner can remove photos after hand back" do
    policy = RepairPolicy.new(@owner, @handed_back_repair)

    assert policy.destroy_intake_photo?
  end

  # ============================================================
  # PUBLIC ACCESS
  # ============================================================

  test "public visitors can read services" do
    policy = ServicePolicy.new(nil, Service.new)

    assert policy.index?
    assert policy.show?

    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
    assert_not policy.view_repair_history?
  end

  test "public visitors cannot access customers" do
    policy = CustomerPolicy.new(nil, @customer)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "public visitors cannot access bikes" do
    policy = BikePolicy.new(nil, @bike)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  # ============================================================
  # EDGE CASES
  # ============================================================

  test "mechanic without staff cannot access unassigned repair" do
    mechanic_without_staff = User.new(role: :mechanic)

    unassigned_repair = Repair.new(
      staff: nil,
      status: :received
    )

    policy = RepairPolicy.new(
      mechanic_without_staff,
      unassigned_repair
    )

    assert_not policy.show?
    assert_not policy.update?
  end

  test "mechanic cannot edit picked up repair even without handed_back_at" do
    repair = Repair.new(
      staff: @mechanic_staff,
      status: :picked_up,
      handed_back_at: nil
    )

    policy = RepairPolicy.new(@mechanic, repair)

    assert_not policy.update?
  end

  test "counter cannot edit picked up repair even without handed_back_at" do
    repair = Repair.new(
      staff: @mechanic_staff,
      status: :picked_up,
      handed_back_at: nil
    )

    policy = RepairPolicy.new(@counter, repair)

    assert_not policy.update?
  end
end
