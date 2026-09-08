# Domain Model

## Diagram Image

![Wheelhouse domain model](domain-model.png)

## Diagram Code

```dbml
Table customers {
  id bigint [pk, increment]
  name varchar [not null]
  phone varchar [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Table bikes {
  id bigint [pk, increment]
  customer_id bigint [not null]
  make varchar [not null]
  model varchar [not null]
  colour varchar [not null]
  serial_number varchar [not null, unique]
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Table staffs {
  id bigint [pk, increment]
  name varchar [not null]
  role varchar [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Table repairs {
  id bigint [pk, increment]
  bike_id bigint [not null]
  staff_id bigint
  status varchar [not null, default: 'Received']
  approval_status varchar
  promised_on date
  quoted_at timestamp
  handed_back_at timestamp
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Table services {
  id bigint [pk, increment]
  name varchar [not null, unique]
  current_price decimal(8,2) [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Table repair_services {
  id bigint [pk, increment]
  repair_id bigint [not null]
  service_id bigint [not null]
  charged_price decimal(8,2) [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]
}

Ref: bikes.customer_id > customers.id
Ref: repairs.bike_id > bikes.id
Ref: repairs.staff_id >? staffs.id
Ref: repair_services.repair_id > repairs.id
Ref: repair_services.service_id > services.id
```

## Changes since Lab 3

- Replaced `mechanics` with `staffs` and added `role` so the database can represent both mechanics and the counter worker.
- Added `colour` to bikes to support distinguishing otherwise identical bikes.
- Renamed `mechanic_id` to `staff_id`; it is nullable because a mechanic may not yet be assigned when a repair is received.
- Renamed `promised_date` to `promised_on` because it represents a calendar day.
- Added `quoted_at` to record when a repair quote was given.
- Added `handed_back_at` to record when a bike was actually returned to its customer.
- Removed `description` from repairs because written diagnosis data is deferred until Lab 9.
- Removed the `photos` table because photo storage is deferred until Lab 9.
- Added Rails timestamps (`created_at` and `updated_at`) to every table.
- Added the required NOT NULL constraints, unique indexes, and decimal precision for monetary values.
- Foreign key constraints are not included because they are deferred to Lab 7.

## Repair Lifecycle

A repair can go through the following states:

`Received → Assessment → Awaiting Approval → In Progress → Ready → Picked Up`

For simple repairs where the customer can approve the work immediately, the repair may move from `Assessment` to `Awaiting Approval` and then directly to `In Progress` once approval is recorded.

For repairs that require a more detailed assessment, the repair remains in `Awaiting Approval` until the customer is contacted and approves the proposed work.

If the customer declines the repair, the repair moves from `Awaiting Approval` to `Declined`, and then to `Picked Up` without any repair work being performed.

Therefore, the allowed transitions are:

- `Received → Assessment`
- `Assessment → Awaiting Approval`
- `Awaiting Approval → In Progress` when the customer approves the repair
- `Awaiting Approval → Declined` when the customer declines the repair
- `In Progress → Ready`
- `Ready → Picked Up`
- `Declined → Picked Up`

Transitions that skip required steps are not allowed. For example:

- `Received → In Progress` is not allowed because the bike has not been assessed or approved.
- `Assessment → In Progress` is not allowed because customer approval must be recorded first.
- `Awaiting Approval → In Progress` is not allowed unless customer approval has been received.
- `Declined → In Progress` is not allowed because the customer declined the repair.
- `In Progress → Picked Up` is not allowed because completed work must first be marked as ready.
- `Picked Up → In Progress` is not allowed because the repair has already ended and the bike has left the shop.

The `status` attribute records the repair's current lifecycle state. The `approval_status` attribute separately records whether approval is awaiting a response, approved, or declined.

## Entity Justification

| Entity        | User stories                                                    |
| ------------- | --------------------------------------------------------------- |
| Customer      | US-01 — Bike registration                                       |
| Bike          | US-01 — Bike registration; US-02 — Bike identification          |
| Staff         | US-04 — Bike problem description; US-06 — Bike status: workable |
| Repair        | US-04 — Bike problem description; US-08 — Bike status: finished |
| Service       | US-05 — Repairs needed; US-13 — Walllist prices                 |
| RepairService | US-05 — Repairs needed; US-12 — Flexible pricing                |

## The Thing and the Copy of the Thing

My system prevents mixing up two similar bikes because it uses serial numbers as identifiers, which are unique to each bike. As for why a quantity column wouldn't work, the quantity does not give you any useful information regarding a bike's identity, nor is it needed by the company to carry out its function, so it wouldn't only fail to give any useful information about the bike's identity, but also add unnecessary information to the database.

## Derived, or Stored?

In my structure, the fact that a bike is overdue isn't stored as its own column because it can be derived from the promised date, the current date, and repair status.

As for a stored value, the price charged for each repair service is stored because it can differ from the current price for each repair service, given that the store wants to be able to change prices depending on their own criteria, and the prices may change over time due to price increases. This way the price that was agreed upon stays fixed independent of other factors.