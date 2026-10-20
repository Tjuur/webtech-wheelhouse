# Wheelhouse API — Version 1

Wheelhouse provides a JSON API for accessing the bike repair shop's services
and repair records.

Base URL (local development):

`http://localhost:3000/api/v1`

## Authentication

Public service reads do not require authentication.

Protected endpoints require an API token sent through the
`Authorization` header:

```http
Authorization: Bearer YOUR_API_TOKEN
```

The token is stored in Rails encrypted credentials under `api_token`.

Never commit the token or `config/master.key` to Git.

## Endpoints

| Method | Endpoint | Authentication | Success | Possible errors |
|---|---|---|---|---|
| GET | `/services` | Public | 200 | — |
| GET | `/services/:id` | Public | 200 | 404 |
| POST | `/services` | Bearer token | 201 | 400, 401, 422 |
| GET | `/repairs` | Bearer token | 200 | 400, 401 |
| GET | `/repairs/:id` | Bearer token | 200 | 401, 404 |

All API responses use JSON, including errors.

## Services

### List services

```http
GET /api/v1/services
```

Returns all services ordered by name.

Example response:

```json
[
  {
    "id": 23,
    "name": "Flat Tire Repair",
    "price": "25.0",
    "repair_count": 3
  },
  {
    "id": 24,
    "name": "Brake Adjustment",
    "price": "35.0",
    "repair_count": 2
  }
]
```

### Show one service

```http
GET /api/v1/services/23
```

Example response:

```json
{
  "id": 23,
  "name": "Flat Tire Repair",
  "price": "25.0",
  "repair_count": 3
}
```

### Create a service

```http
POST /api/v1/services
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json
```

Request body:

```json
{
  "service": {
    "name": "Suspension Service",
    "current_price": 75.00
  }
}
```

Successful response: **201 Created**

```json
{
  "id": 45,
  "name": "Suspension Service",
  "price": "75.0",
  "repair_count": 0
}
```

The response includes a `Location` header pointing to the newly created
service's API URL.

Only `name` and `current_price` are accepted from the request body.

An empty or missing service object returns **400 Bad Request**.

Invalid service attributes return **422 Unprocessable Entity**.

## Repairs

Repair endpoints require authentication.

### List repairs

```http
GET /api/v1/repairs
Authorization: Bearer YOUR_API_TOKEN
```

Returns repairs ordered by promised date.

Example response:

```json
[
  {
    "id": 1,
    "state": "Ready",
    "received_on": "2026-10-01",
    "promised_on": "2026-10-08",
    "handed_back_on": null,
    "bike": {
      "brand": "Trek",
      "model": "FX 3",
      "serial_number": "TRK-001"
    },
    "customer": {
      "name": "Example Customer"
    },
    "lines": [
      {
        "service": "Flat Tire Repair",
        "charged_price": "25.0"
      }
    ],
    "total": "25.0",
    "overdue": false,
    "customer_answer": null
  }
]
```

### Show one repair

```http
GET /api/v1/repairs/1
Authorization: Bearer YOUR_API_TOKEN
```

Returns one repair using the same document structure as the collection.

### Filter repairs by state

```http
GET /api/v1/repairs?state=Ready
Authorization: Bearer YOUR_API_TOKEN
```

The `state` parameter must match one of the repair states defined by
the Rails `Repair` model.

An invalid state returns **400 Bad Request**, including the valid states
in the error message.

## Data representation

### Prices

All monetary values are serialized as **decimal strings**, not JSON numbers.

For example:

```json
{
  "price": "75.0"
}
```

The client can format these values for display with two decimal places.

### Service fields

- `id`: Service identifier.
- `name`: Service name.
- `price`: Current service price, represented as a decimal string.
- `repair_count`: Number of repair lines associated with the service.

`repair_count` is calculated from the service's associated repair records;
it is not a database column.

### Repair fields

- `id`: Repair identifier.
- `state`: Current repair status.
- `received_on`: Date the repair was created.
- `promised_on`: Promised completion date.
- `handed_back_on`: Date the bike was returned, or `null`.
- `bike`: Bike brand, model, and serial number.
- `customer`: Customer name.
- `lines`: Services performed and their charged prices.
- `total`: Sum of the repair's charged prices, as a decimal string.
- `overdue`: Whether the repair is overdue.
- `customer_answer`: Customer approval status, or `null`.

The API intentionally omits customer phone numbers, database foreign keys,
intake photos, and rich-text diagnosis content.

`total` is calculated from the repair lines rather than stored as a
database column.

## Error responses

All API errors use this structure:

```json
{
  "errors": [
    "Error description"
  ]
}
```

### 400 Bad Request

Used for malformed or missing service attributes and invalid repair states.

Example:

```json
{
  "errors": [
    "Invalid state. Valid states: Received, Assessment, Awaiting Approval, In Progress, Ready, Declined, Picked Up"
  ]
}
```

### 401 Unauthorized

Used when a protected endpoint receives no token or an invalid token.

```json
{
  "errors": [
    "Unauthorized"
  ]
}
```

### 404 Not Found

Used when a requested service or repair does not exist.

```json
{
  "errors": [
    "Couldn't find Service with 'id'=999999"
  ]
}
```

### 422 Unprocessable Entity

Used when service validation fails.

```json
{
  "errors": [
    "Name has already been taken"
  ]
}
```

## CORS

Browser cross-origin access is permitted only from:

- `https://tjuur.github.io`
- `http://localhost:8000`

CORS is enabled only for public service GET endpoints.

Protected repair endpoints and service creation do not permit cross-origin
browser access.

Requests without an `Origin` header, such as ordinary `curl` requests,
can access the API according to their authentication requirements.

## Personal website integration

The personal website is published at:

https://tjuur.github.io/webtech-lab-01/

Its JavaScript requests the public services API using `fetch()` and
`async/await`.

Service rows are created dynamically using DOM methods and `textContent`.

The page also supports looking up individual services by ID.

The API must be running at `http://localhost:3000` for these requests
to succeed.