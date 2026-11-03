# frozen_string_literal: true

service_data = [
  [ "Flat Tire Repair", 15.00 ],
  [ "Brake Adjustment", 20.00 ],
  [ "Gear Adjustment", 20.00 ],
  [ "Chain Replacement", 25.00 ],
  [ "Tube Replacement", 18.00 ],
  [ "Tire Replacement", 30.00 ],
  [ "Wheel Truing", 25.00 ],
  [ "Brake Pad Replacement", 30.00 ],
  [ "Cable Replacement", 25.00 ],
  [ "Drivetrain Cleaning", 35.00 ],
  [ "Basic Tune-Up", 50.00 ],
  [ "Full Tune-Up", 90.00 ],
  [ "Chain Cleaning", 18.00 ],
  [ "Chain Lubrication", 12.00 ],
  [ "Derailleur Adjustment", 22.00 ],
  [ "Bottom Bracket Service", 45.00 ],
  [ "Headset Adjustment", 20.00 ],
  [ "Pedal Replacement", 18.00 ],
  [ "Cassette Replacement", 35.00 ],
  [ "Spoke Replacement", 20.00 ],
  [ "Wheel Replacement", 50.00 ],
  [ "Brake Cable Replacement", 28.00 ]
]

service_data.each do |name, price|
  service = Service.find_or_initialize_by(name: name)
  service.current_price = price if service.new_record?
  service.save! if service.changed?
end

staff_data = [
  [ "Hank Schrader", "mechanic" ],
  [ "Walter White", "mechanic" ],
  [ "Jessie Pinkman", "mechanic" ],
  [ "Scarlett Johansson", "counter" ]
]

staff_data.each do |name, role|
  member = Staff.find_or_initialize_by(name: name)
  member.role = role if member.new_record?
  member.save! if member.changed?
end

staff_by_name = Staff.where(
  name: staff_data.map(&:first)
).index_by(&:name)

account_data = [
  {
    staff_name: "Hank Schrader",
    email: "hank@wheelhouse.cl",
    password: "HankPassword123!",
    role: :owner
  },
  {
    staff_name: "Walter White",
    email: "walter@wheelhouse.cl",
    password: "WalterPassword123!",
    role: :mechanic
  },
  {
    staff_name: "Jessie Pinkman",
    email: "jessie@wheelhouse.cl",
    password: "JessiePassword123!",
    role: :mechanic
  },
  {
    staff_name: "Scarlett Johansson",
    email: "scarlett@wheelhouse.cl",
    password: "ScarlettPassword123!",
    role: :counter
  },
  {
    staff_name: nil,
    email: "guest@wheelhouse.cl",
    password: "GuestPassword123!",
    role: :counter
  }
]

account_data.each do |account|
  user = User.find_or_initialize_by(
    email_address: account[:email]
  )

  if user.new_record?
    user.password = account[:password]
    user.password_confirmation = account[:password]
  end

  user.role = account[:role]
  user.staff = account[:staff_name] ? staff_by_name.fetch(account[:staff_name]) : nil

  user.save! if user.new_record? || user.changed?
end

customer_data = [
  [ "Laura Bennett", "555-0101" ],
  [ "James Carter", "555-0102" ],
  [ "Maya Singh", "555-0103" ],
  [ "Oliver Grant", "555-0104" ],
  [ "Emma Collins", "555-0105" ],
  [ "Noah Mitchell", "555-0106" ],
  [ "Sofia Ramirez", "555-0107" ],
  [ "Ethan Brooks", "555-0108" ],
  [ "Chloe Martin", "555-0109" ],
  [ "Lucas Turner", "555-0110" ]
]

customer_data.each do |name, phone|
  customer = Customer.find_or_initialize_by(name: name, phone: phone)
  customer.save! if customer.new_record?
end

customers_by_name = Customer.where(
  name: customer_data.map(&:first)
).index_by(&:name)

bike_data = [
  [ "Laura Bennett", "Trek", "FX 2", "Black", "TRK-FX2-1001" ],
  [ "Laura Bennett", "Trek", "FX 2", "Black", "TRK-FX2-1002" ],
  [ "James Carter", "Giant", "Escape 3", "Blue", "GNT-ESC-2001" ],
  [ "Maya Singh", "Specialized", "Sirrus 2.0", "Red", "SPZ-SIR-3001" ],
  [ "Oliver Grant", "Cannondale", "Quick 4", "Green", "CAN-QCK-4001" ],
  [ "Emma Collins", "Scott", "Sub Cross 40", "Grey", "SCT-SUB-5001" ],
  [ "Noah Mitchell", "Merida", "Crossway 20", "Silver", "MER-CRS-6001" ],
  [ "Sofia Ramirez", "Cube", "Hyde", "Black", "CUB-HYD-7001" ],
  [ "Ethan Brooks", "Bianchi", "C-Sport 2", "White", "BIA-CSP-8001" ],
  [ "Chloe Martin", "Orbea", "Vector 20", "Blue", "ORB-VEC-9001" ],
  [ "Lucas Turner", "Trek", "Marlin 5", "Red", "TRK-MAR-10001" ],
  [ "Oliver Grant", "Giant", "Talon 2", "Black", "GNT-TAL-11001" ]
]

bike_data.each do |customer_name, make, model, colour, serial|
  bike = Bike.find_or_initialize_by(serial_number: serial)

  if bike.new_record?
    bike.assign_attributes(
      customer: customers_by_name.fetch(customer_name),
      make: make,
      model: model,
      colour: colour
    )

    bike.save!
  end
end

bikes_by_serial = Bike.where(
  serial_number: bike_data.map(&:last)
).index_by(&:serial_number)

same_day = 10.days.ago.change(hour: 9)
old_repair_date = 2.years.ago

repair_data = [
  {
    key: "demo-repair-001",
    serial: "TRK-FX2-1001",
    staff: nil,
    status: "Received",
    approval: nil,
    promised_on: Date.current + 2.days
  },
  {
    key: "demo-repair-002",
    serial: "TRK-FX2-1002",
    staff: "Hank Schrader",
    status: "Assessment",
    approval: nil,
    promised_on: Date.current + 3.days
  },
  {
    key: "demo-repair-003",
    serial: "GNT-ESC-2001",
    staff: "Walter White",
    status: "Awaiting Approval",
    approval: "awaiting",
    promised_on: Date.current + 2.days,
    quoted_at: 1.day.ago
  },
  {
    key: "demo-repair-004",
    serial: "SPZ-SIR-3001",
    staff: "Jessie Pinkman",
    status: "In Progress",
    approval: "approved",
    promised_on: Date.current - 2.days,
    quoted_at: 3.days.ago,
    created_at: 5.days.ago,
    updated_at: 1.day.ago
  },
  {
    key: "demo-repair-005",
    serial: "CAN-QCK-4001",
    staff: "Hank Schrader",
    status: "Ready",
    approval: "approved",
    promised_on: Date.current,
    quoted_at: 2.days.ago,
    created_at: 3.days.ago
  },
  {
    key: "demo-repair-006",
    serial: "SCT-SUB-5001",
    staff: "Walter White",
    status: "Declined",
    approval: "declined",
    promised_on: Date.current + 1.day,
    quoted_at: 2.days.ago
  },
  {
    key: "demo-repair-007",
    serial: "MER-CRS-6001",
    staff: "Jessie Pinkman",
    status: "Picked Up",
    approval: "approved",
    promised_on: Date.current - 5.days,
    quoted_at: 7.days.ago,
    handed_back_at: 5.days.ago,
    created_at: 8.days.ago,
    updated_at: 5.days.ago
  },
  {
    key: "demo-repair-008",
    serial: "CUB-HYD-7001",
    staff: "Hank Schrader",
    status: "Picked Up",
    approval: "approved",
    promised_on: same_day.to_date,
    quoted_at: same_day + 1.hour,
    handed_back_at: same_day + 6.hours,
    created_at: same_day,
    updated_at: same_day + 6.hours
  },
  {
    key: "demo-repair-009",
    serial: "TRK-FX2-1001",
    staff: "Walter White",
    status: "Picked Up",
    approval: "approved",
    promised_on: old_repair_date.to_date + 2.days,
    quoted_at: old_repair_date + 2.hours,
    handed_back_at: old_repair_date + 2.days,
    created_at: old_repair_date,
    updated_at: old_repair_date + 2.days
  },
  {
    key: "demo-repair-010",
    serial: "BIA-CSP-8001",
    staff: "Jessie Pinkman",
    status: "In Progress",
    approval: "approved",
    promised_on: Date.current + 2.days,
    quoted_at: 1.day.ago
  },
  {
    key: "demo-repair-011",
    serial: "ORB-VEC-9001",
    staff: "Hank Schrader",
    status: "Ready",
    approval: "approved",
    promised_on: Date.current - 1.day,
    quoted_at: 4.days.ago,
    created_at: 5.days.ago
  },
  {
    key: "demo-repair-012",
    serial: "GNT-TAL-11001",
    staff: "Walter White",
    status: "Assessment",
    approval: nil,
    promised_on: Date.current + 4.days
  },
  {
    key: "demo-repair-013",
    serial: "GNT-ESC-2001",
    staff: "Jessie Pinkman",
    status: "Picked Up",
    approval: "approved",
    promised_on: Date.current - 20.days,
    quoted_at: 23.days.ago,
    handed_back_at: 20.days.ago,
    created_at: 24.days.ago,
    updated_at: 20.days.ago
  },
  {
    key: "demo-repair-014",
    serial: "SPZ-SIR-3001",
    staff: "Hank Schrader",
    status: "Picked Up",
    approval: "declined",
    promised_on: Date.current - 15.days,
    quoted_at: 17.days.ago,
    handed_back_at: 16.days.ago,
    created_at: 18.days.ago,
    updated_at: 16.days.ago
  },
  {
    key: "demo-repair-015",
    serial: "CAN-QCK-4001",
    staff: "Walter White",
    status: "Awaiting Approval",
    approval: "awaiting",
    promised_on: Date.current + 3.days,
    quoted_at: Time.current
  }
]

repair_service_data = {
  "demo-repair-001" => [ [ "Flat Tire Repair", 15.00 ] ],
  "demo-repair-002" => [ [ "Brake Adjustment", 20.00 ] ],
  "demo-repair-003" => [ [ "Full Tune-Up", 90.00 ] ],
  "demo-repair-004" => [
    [ "Gear Adjustment", 20.00 ],
    [ "Chain Replacement", 25.00 ]
  ],
  "demo-repair-005" => [ [ "Wheel Truing", 25.00 ] ],
  "demo-repair-006" => [ [ "Bottom Bracket Service", 45.00 ] ],
  "demo-repair-007" => [
    [ "Basic Tune-Up", 50.00 ],
    [ "Brake Pad Replacement", 30.00 ]
  ],
  "demo-repair-008" => [ [ "Flat Tire Repair", 15.00 ] ],
  "demo-repair-009" => [
    [ "Basic Tune-Up", 40.00 ],
    [ "Cable Replacement", 20.00 ]
  ],
  "demo-repair-010" => [
    [ "Drivetrain Cleaning", 35.00 ],
    [ "Chain Lubrication", 12.00 ]
  ],
  "demo-repair-011" => [ [ "Wheel Replacement", 50.00 ] ],
  "demo-repair-012" => [ [ "Headset Adjustment", 20.00 ] ],
  "demo-repair-013" => [
    [ "Cassette Replacement", 35.00 ],
    [ "Chain Replacement", 22.00 ]
  ],
  "demo-repair-014" => [ [ "Full Tune-Up", 85.00 ] ],
  "demo-repair-015" => [ [ "Brake Cable Replacement", 28.00 ] ]
}

diagnosis_data = {
  "demo-repair-002" =>
    "<p><strong>Initial inspection:</strong> front brake is rubbing against the rim.</p>",
  "demo-repair-003" =>
    "<p>Drivetrain inspected. Customer approval is required before work begins.</p>",
  "demo-repair-004" =>
    "<p><strong>Gear shifting issue confirmed.</strong></p><ul><li>Chain is worn</li><li>Rear derailleur needs adjustment</li></ul>",
  "demo-repair-005" =>
    "<p>Rear wheel is slightly out of true. Spoke tension is uneven.</p>",
  "demo-repair-006" =>
    "<p><strong>Bottom bracket has excessive play.</strong> Customer declined the proposed repair.</p>",
  "demo-repair-007" =>
    "<p>Bike serviced and road tested successfully. Brakes and drivetrain are operating normally.</p>",
  "demo-repair-008" =>
    "<p>Rear tire was flat on arrival. Tube inspected and puncture located.</p>",
  "demo-repair-009" =>
    "<p><strong>General wear from regular use.</strong></p><ul><li>Chain cleaned</li><li>Cables inspected</li><li>Brakes checked</li></ul>",
  "demo-repair-010" =>
    "<p>Drivetrain contains heavy dirt buildup. Chain requires cleaning and lubrication.</p>",
  "demo-repair-011" =>
    "<p>Rear wheel is damaged and requires replacement before the bike is safe to ride.</p>",
  "demo-repair-012" =>
    "<p>Headset has minor play. Further adjustment is required.</p>",
  "demo-repair-013" =>
    "<p><strong>Cassette and chain show significant wear.</strong> Replacement completed.</p>",
  "demo-repair-014" =>
    "<p>Full tune-up completed after customer declined additional optional work.</p>",
  "demo-repair-015" =>
    "<p>Brake cable is frayed and should be replaced before regular use.</p>"
}

services_by_name = Service.where(
  name: service_data.map(&:first)
).index_by(&:name)

receivers = [
  User.find_by!(email_address: "scarlett@wheelhouse.cl"),
  User.find_by!(email_address: "hank@wheelhouse.cl")
]

repairs_by_key = {}

repair_data.each_with_index do |data, index|
  key = data.fetch(:key)
  bike = bikes_by_serial.fetch(data.fetch(:serial))
  staff_member = data[:staff] ? staff_by_name.fetch(data[:staff]) : nil

  repair = Repair.find_by(seed_key: key)

  if repair.nil?
    candidates = Repair.where(
      seed_key: nil,
      bike_id: bike.id,
      staff_id: staff_member&.id,
      status: data.fetch(:status),
      approval_status: data[:approval]
    )

    expected_services = repair_service_data.fetch(key).map(&:first).sort

    candidates = candidates.select do |candidate|
      actual_services = candidate.repair_services
        .includes(:service)
        .map { |association| association.service.name }
        .sort

      next false unless actual_services == expected_services

      if data[:created_at]
        next false unless candidate.created_at.to_date == data[:created_at].to_date
      end

      true
    end

    if candidates.size > 1
      raise "Ambiguous legacy repair match for #{key}"
    end

    repair = candidates.first
  end

  if repair
    repair.update!(seed_key: key) if repair.seed_key.nil?
  else
    attributes = {
      seed_key: key,
      bike: bike,
      staff: staff_member,
      status: data.fetch(:status),
      approval_status: data[:approval],
      promised_on: data[:promised_on],
      quoted_at: data[:quoted_at],
      handed_back_at: data[:handed_back_at]
    }

    attributes[:received_by_user] = receivers[index] if index < receivers.length
    attributes[:created_at] = data[:created_at] if data[:created_at]
    attributes[:updated_at] = data[:updated_at] if data[:updated_at]

    repair = Repair.create!(attributes)
  end

  repairs_by_key[key] = repair
end

repair_service_data.each do |key, entries|
  repair = repairs_by_key.fetch(key)

  entries.each do |service_name, price|
    service = services_by_name.fetch(service_name)

    association = RepairService.find_or_initialize_by(
      repair: repair,
      service: service
    )

    if association.new_record?
      association.charged_price = price
      association.save!
    end
  end
end

diagnosis_data.each do |key, html|
  repair = repairs_by_key.fetch(key)

  next if repair.diagnosis.present?

  repair.diagnosis = html
  repair.save!
end

seed_image_path = Rails.root.join("db", "seeds", "intake-bike.jpg")

if File.exist?(seed_image_path)
  repair_data.first(10).each_with_index do |data, index|
    repair = repairs_by_key.fetch(data.fetch(:key))
    desired_count = index.zero? ? 4 : 1
    existing_count = repair.intake_photos.count

    next if existing_count >= desired_count

    (existing_count...desired_count).each do |photo_index|
      File.open(seed_image_path, "rb") do |file|
        repair.intake_photos.attach(
          io: file,
          filename: "#{data.fetch(:key)}-intake-#{photo_index + 1}.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end

puts "Database seeds completed."
puts "Services: #{Service.count}"
puts "Staff: #{Staff.count}"
puts "Users: #{User.count}"
puts "Customers: #{Customer.count}"
puts "Bikes: #{Bike.count}"
puts "Repairs: #{Repair.count}"
puts "Repair services: #{RepairService.count}"
puts "Seeded repairs: #{Repair.where.not(seed_key: nil).count}"
