RepairService.delete_all
Repair.delete_all
Bike.delete_all
Customer.delete_all
Staff.delete_all
Service.delete_all

services = [
  ["Flat Tire Repair", 15.00],
  ["Brake Adjustment", 20.00],
  ["Gear Adjustment", 20.00],
  ["Chain Replacement", 25.00],
  ["Tube Replacement", 18.00],
  ["Tire Replacement", 30.00],
  ["Wheel Truing", 25.00],
  ["Brake Pad Replacement", 30.00],
  ["Cable Replacement", 25.00],
  ["Drivetrain Cleaning", 35.00],
  ["Basic Tune-Up", 50.00],
  ["Full Tune-Up", 90.00],
  ["Chain Cleaning", 18.00],
  ["Chain Lubrication", 12.00],
  ["Derailleur Adjustment", 22.00],
  ["Bottom Bracket Service", 45.00],
  ["Headset Adjustment", 20.00],
  ["Pedal Replacement", 18.00],
  ["Cassette Replacement", 35.00],
  ["Spoke Replacement", 20.00],
  ["Wheel Replacement", 50.00],
  ["Brake Cable Replacement", 28.00]
]

services.each do |name, price|
  Service.create!(
    name: name,
    current_price: price
  )
end

staff_members = [
  ["Hank Schrader", "mechanic"],
  ["Walter White", "mechanic"],
  ["Jessie Pinkman", "mechanic"],
  ["Scarlett Johansson", "counter"]
]

staff_members.each do |name, role|
  Staff.create!(
    name: name,
    role: role
  )
end


customers = [
  ["Laura Bennett", "555-0101"],
  ["James Carter", "555-0102"],
  ["Maya Singh", "555-0103"],
  ["Oliver Grant", "555-0104"],
  ["Emma Collins", "555-0105"],
  ["Noah Mitchell", "555-0106"],
  ["Sofia Ramirez", "555-0107"],
  ["Ethan Brooks", "555-0108"],
  ["Chloe Martin", "555-0109"],
  ["Lucas Turner", "555-0110"]
]

customers.each do |name, phone|
  Customer.create!(
    name: name,
    phone: phone
  )
end


customers = Customer.order(:id).to_a

bikes = [
  [customers[0].id, "Trek", "FX 2", "Black", "TRK-FX2-1001"],
  [customers[0].id, "Trek", "FX 2", "Black", "TRK-FX2-1002"],
  [customers[1].id, "Giant", "Escape 3", "Blue", "GNT-ESC-2001"],
  [customers[2].id, "Specialized", "Sirrus 2.0", "Red", "SPZ-SIR-3001"],
  [customers[3].id, "Cannondale", "Quick 4", "Green", "CAN-QCK-4001"],
  [customers[4].id, "Scott", "Sub Cross 40", "Grey", "SCT-SUB-5001"],
  [customers[5].id, "Merida", "Crossway 20", "Silver", "MER-CRS-6001"],
  [customers[6].id, "Cube", "Hyde", "Black", "CUB-HYD-7001"],
  [customers[7].id, "Bianchi", "C-Sport 2", "White", "BIA-CSP-8001"],
  [customers[8].id, "Orbea", "Vector 20", "Blue", "ORB-VEC-9001"],
  [customers[9].id, "Trek", "Marlin 5", "Red", "TRK-MAR-10001"],
  [customers[3].id, "Giant", "Talon 2", "Black", "GNT-TAL-11001"]
]

bikes.each do |customer_id, make, model, colour, serial_number|
  Bike.create!(
    customer_id: customer_id,
    make: make,
    model: model,
    colour: colour,
    serial_number: serial_number
  )
end


bikes = Bike.order(:id).to_a
staff = Staff.order(:id).to_a

repairs = [
  {
    bike_id: bikes[0].id,
    staff_id: nil,
    status: "Received",
    approval_status: nil,
    promised_on: Date.current + 2.days
  },

  {
    bike_id: bikes[1].id,
    staff_id: staff[0].id,
    status: "Assessment",
    approval_status: nil,
    promised_on: Date.current + 3.days
  },

  {
    bike_id: bikes[2].id,
    staff_id: staff[1].id,
    status: "Awaiting Approval",
    approval_status: "awaiting",
    promised_on: Date.current + 2.days,
    quoted_at: 1.day.ago
  },

  {
    bike_id: bikes[3].id,
    staff_id: staff[2].id,
    status: "In Progress",
    approval_status: "approved",
    promised_on: Date.current - 2.days,
    quoted_at: 3.days.ago
  },

  {
    bike_id: bikes[4].id,
    staff_id: staff[0].id,
    status: "Ready",
    approval_status: "approved",
    promised_on: Date.current,
    quoted_at: 2.days.ago
  },

  {
    bike_id: bikes[5].id,
    staff_id: staff[1].id,
    status: "Declined",
    approval_status: "declined",
    promised_on: Date.current + 1.day,
    quoted_at: 2.days.ago
  },

  {
    bike_id: bikes[6].id,
    staff_id: staff[2].id,
    status: "Picked Up",
    approval_status: "approved",
    promised_on: Date.current - 5.days,
    quoted_at: 7.days.ago,
    handed_back_at: 5.days.ago
  }
]
same_day = 10.days.ago.change(hour: 9)
old_repair_date = 2.years.ago

repairs += [
  {
    bike_id: bikes[7].id,
    staff_id: staff[0].id,
    status: "Picked Up",
    approval_status: "approved",
    promised_on: same_day.to_date,
    quoted_at: same_day + 1.hour,
    handed_back_at: same_day + 6.hours,
    created_at: same_day,
    updated_at: same_day + 6.hours
  },

  {
    bike_id: bikes[0].id,
    staff_id: staff[1].id,
    status: "Picked Up",
    approval_status: "approved",
    promised_on: old_repair_date.to_date + 2.days,
    quoted_at: old_repair_date + 2.hours,
    handed_back_at: old_repair_date + 2.days,
    created_at: old_repair_date,
    updated_at: old_repair_date + 2.days
  },

  {
    bike_id: bikes[8].id,
    staff_id: staff[2].id,
    status: "In Progress",
    approval_status: "approved",
    promised_on: Date.current + 2.days,
    quoted_at: 1.day.ago
  },

  {
    bike_id: bikes[9].id,
    staff_id: staff[0].id,
    status: "Ready",
    approval_status: "approved",
    promised_on: Date.current - 1.day,
    quoted_at: 4.days.ago
  },

  {
    bike_id: bikes[11].id,
    staff_id: staff[1].id,
    status: "Assessment",
    approval_status: nil,
    promised_on: Date.current + 4.days
  },

  {
    bike_id: bikes[2].id,
    staff_id: staff[2].id,
    status: "Picked Up",
    approval_status: "approved",
    promised_on: Date.current - 20.days,
    quoted_at: 23.days.ago,
    handed_back_at: 20.days.ago,
    created_at: 24.days.ago,
    updated_at: 20.days.ago
  },

  {
    bike_id: bikes[3].id,
    staff_id: staff[0].id,
    status: "Picked Up",
    approval_status: "declined",
    promised_on: Date.current - 15.days,
    quoted_at: 17.days.ago,
    handed_back_at: 16.days.ago,
    created_at: 18.days.ago,
    updated_at: 16.days.ago
  },

  {
    bike_id: bikes[4].id,
    staff_id: staff[1].id,
    status: "Awaiting Approval",
    approval_status: "awaiting",
    promised_on: Date.current + 3.days,
    quoted_at: Time.current
  }
]

repairs.each do |repair|
  Repair.create!(repair)
end

repairs = Repair.order(:id).to_a
services = Service.order(:name).to_a

service_by_name = services.index_by(&:name)

repair_services = [
  [repairs[0].id, service_by_name["Flat Tire Repair"].id, 15.00],
  [repairs[1].id, service_by_name["Brake Adjustment"].id, 20.00],
  [repairs[2].id, service_by_name["Full Tune-Up"].id, 90.00],

  [repairs[3].id, service_by_name["Gear Adjustment"].id, 20.00],
  [repairs[3].id, service_by_name["Chain Replacement"].id, 25.00],

  [repairs[4].id, service_by_name["Wheel Truing"].id, 25.00],

  [repairs[5].id, service_by_name["Bottom Bracket Service"].id, 45.00],

  [repairs[6].id, service_by_name["Basic Tune-Up"].id, 50.00],
  [repairs[6].id, service_by_name["Brake Pad Replacement"].id, 30.00],

  [repairs[7].id, service_by_name["Flat Tire Repair"].id, 15.00],

  [repairs[8].id, service_by_name["Basic Tune-Up"].id, 40.00],
  [repairs[8].id, service_by_name["Cable Replacement"].id, 20.00],

  [repairs[9].id, service_by_name["Drivetrain Cleaning"].id, 35.00],
  [repairs[9].id, service_by_name["Chain Lubrication"].id, 12.00],

  [repairs[10].id, service_by_name["Wheel Replacement"].id, 50.00],

  [repairs[11].id, service_by_name["Headset Adjustment"].id, 20.00],

  [repairs[12].id, service_by_name["Cassette Replacement"].id, 35.00],
  [repairs[12].id, service_by_name["Chain Replacement"].id, 22.00],

  [repairs[13].id, service_by_name["Full Tune-Up"].id, 85.00],

  [repairs[14].id, service_by_name["Brake Cable Replacement"].id, 28.00]
]

repair_services.each do |repair_id, service_id, charged_price|
  RepairService.create!(
    repair_id: repair_id,
    service_id: service_id,
    charged_price: charged_price
  )
end