# Wheelhouse

Wheelhouse is a web application for a neighbourhood bicycle repair shop, developed using Ruby on Rails.

The application manages customers, bikes, repairs, services, staff, intake photos, and repair diagnoses.

It also provides a versioned JSON API that allows external clients to retrieve service prices and access repair information through authenticated requests.

## Documentation

The specification and design documents from Lab 3 are available here:

- [User Stories](docs/user-stories.md)
- [Domain Model](docs/domain-model.md)
- [Decisions](docs/decisions.md)
- [Wireframes](docs/wireframes.md)

API documentation:

- [API Reference](docs/api.md)

The API reference includes endpoint descriptions, authentication requirements, example JSON responses, error handling, and CORS restrictions.

## Prerequisites

Before running Wheelhouse, make sure the following are installed:

- Ruby 4.0.4
- Rails 8.0
- Node.js 26.1.0
- Yarn
- PostgreSQL
- libvips

PostgreSQL must be running locally, and the PostgreSQL role used by the application must have permission to create databases.

Wheelhouse uses libvips to process intake photos and generate image variants such as thumbnails.

### Installing libvips

On macOS with Homebrew:

```bash
brew install vips
```

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install libvips
```

You can verify that libvips is installed with:

```bash
vips --version
```

## Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/Tjuur/webtech-wheelhouse.git
cd webtech-wheelhouse
```

### 2. Install dependencies

Install the Ruby and JavaScript dependencies:

```bash
bundle install
yarn install
```

### 3. Configure Rails credentials

Wheelhouse uses Rails encrypted credentials to store the API authentication token.

The token is required to access protected API endpoints.

On a fresh clone, create or edit the credentials file using:

```bash
EDITOR="nano" bin/rails credentials:edit
```

Add the following entry:

```yaml
api_token: YOUR_SECRET_TOKEN
```

Replace `YOUR_SECRET_TOKEN` with a securely generated token.

You can generate a random token using:

```bash
bin/rails secret
```

Copy the generated value into the credentials file.

Save and exit the editor.

**Important security considerations:**

- Never commit the API token to Git.
- Never commit `config/master.key`.
- Do not include real API tokens in documentation or screenshots.
- API tokens must only be transmitted through the `Authorization` header.

Rails credentials are encrypted, allowing the application to retrieve the token without exposing it in source code.

If you are using an existing encrypted credentials file, you must have its matching master key to edit or decrypt it. Otherwise, create a new credentials file and master key for your local environment.

### 4. Set up the database

Make sure PostgreSQL is running.

Create the database, run migrations, and load development seed data:

```bash
bin/rails db:setup
```

The seed data includes:

- Customers
- Bikes
- Staff
- Services
- Repairs
- Repair service lines
- Diagnoses
- Intake photos

### 5. Start the application

```bash
bin/dev
```

The application runs locally at:

`http://localhost:3000`

The main pages include:

| Page | URL |
|---|---|
| Home | `/` |
| Repairs | `/repairs` |
| Services | `/services` |
| Customers | `/customers` |
| Bikes | `/bikes` |
| Staff | `/staff` |

The repairs page displays intake-photo thumbnails and diagnosis excerpts.

## JSON API

Wheelhouse provides a versioned API under:

`http://localhost:3000/api/v1`

The API uses JSON for both successful responses and errors.

### Available endpoints

| Method | Endpoint | Authentication | Description |
|---|---|---|---|
| GET | `/api/v1/services` | Public | List all services and prices |
| GET | `/api/v1/services/:id` | Public | Retrieve a single service |
| POST | `/api/v1/services` | Bearer token | Create a new service |
| GET | `/api/v1/repairs` | Bearer token | List repairs |
| GET | `/api/v1/repairs/:id` | Bearer token | Retrieve a single repair |

The API controllers inherit from `ActionController::API` and are separate from the application's HTML controllers.

Existing HTML routes and functionality remain unchanged.

### Public API example

To retrieve the service price list:

```bash
curl -i http://localhost:3000/api/v1/services
```

No authentication is required.

A successful request returns HTTP `200 OK` with a JSON array.

Example:

```json
[
  {
    "id": 23,
    "name": "Flat Tire Repair",
    "price": "25.0",
    "repair_count": 3
  }
]
```

Prices are represented as decimal strings.

The `repair_count` field is calculated from associated repair service records rather than stored as a database column.

To retrieve a single service:

```bash
curl -i http://localhost:3000/api/v1/services/23
```

### Authenticated API requests

Protected endpoints require a Bearer token.

For local testing, store your token in a shell environment variable:

```bash
export WHEELHOUSE_TOKEN="YOUR_SECRET_TOKEN"
```

Replace the placeholder with the token stored in Rails credentials.

This variable is used only by the `curl` examples. Rails itself reads the token from encrypted credentials.

**Do not commit this token or paste its actual value into the README.**

To retrieve repairs:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  http://localhost:3000/api/v1/repairs
```

To retrieve one repair:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  http://localhost:3000/api/v1/repairs/1
```

To filter repairs by state:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  "http://localhost:3000/api/v1/repairs?state=Ready"
```

The `state` parameter must match a valid repair status.

Invalid states return HTTP `400 Bad Request` with a JSON error.

### Creating a service

Creating a service requires authentication.

Example:

```bash
curl -i -X POST \
  http://localhost:3000/api/v1/services \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "name": "Suspension Service",
      "current_price": 75.00
    }
  }'
```

A successful request returns:

- HTTP `201 Created`.
- A JSON document describing the new service.
- A `Location` header containing the new service's API URL.

Invalid attributes return HTTP `422 Unprocessable Entity`.

Missing service attributes return HTTP `400 Bad Request`.

### API errors

All API errors follow the same JSON structure:

```json
{
  "errors": [
    "Error description"
  ]
}
```

The API uses the following HTTP status codes:

| Status | Meaning |
|---|---|
| 200 | Successful GET request |
| 201 | Service successfully created |
| 400 | Invalid request or parameters |
| 401 | Missing or invalid authentication |
| 404 | Requested record does not exist |
| 422 | Service validation failed |

For complete examples and field descriptions, see [docs/api.md](docs/api.md).

## API Security

The API uses token-based authentication.

Protected requests must provide:

```http
Authorization: Bearer YOUR_API_TOKEN
```

The expected token is stored in Rails encrypted credentials.

The application uses timing-safe comparison when validating tokens.

Authentication is required for:

- Reading repair collections.
- Reading individual repairs.
- Creating services.

Reading service information is public.

The API does not expose customer phone numbers or internal foreign keys in its repair responses.

## CORS Configuration

Wheelhouse allows browser-based cross-origin requests from exactly two origins:

- `https://tjuur.github.io`
- `http://localhost:8000`

CORS is enabled only for public service GET endpoints.

The protected repair endpoints and service creation endpoint are not exposed through CORS.

Requests made using tools such as `curl` do not require CORS permissions.

## Personal Website Integration

The public Wheelhouse price list is integrated into my personal website.

**Published website:**

https://tjuur.github.io/webtech-lab-01/

**Website repository:**

https://github.com/Tjuur/webtech-lab-01

The website uses JavaScript's Fetch API to retrieve the public services collection.

Its features include:

- Dynamically generated service rows.
- Formatted prices with two decimal places.
- Loading and network-error messages.
- HTTP error handling.
- Service lookup by ID.
- Display of service name, price, and repair count.

The JavaScript uses `async/await` and checks `response.ok`.

Service information is inserted using safe DOM methods such as `createElement()` and `textContent`, rather than HTML injection.

### Testing the integration locally

The personal website expects the Wheelhouse API to run on port `3000`.

Start Wheelhouse in one terminal:

```bash
cd webtech-wheelhouse
bin/dev
```

In a second terminal, navigate to the personal website repository:

```bash
cd webtech-lab-01
python3 -m http.server 8000
```

Open:

`http://localhost:8000`

Scroll to the Wheelhouse section to see the service price list.

You can also enter a service ID to retrieve its details.

**Note:** The published GitHub Pages website also requests `http://localhost:3000`. Therefore, the Rails API must be running on the visitor's own computer for the price list to load. This integration is intended for local development and demonstration; the API is not publicly deployed.

## Uploaded Files

In development, uploaded files are stored locally in the `storage/` directory using Active Storage.

Files uploaded while using the application should not be committed to Git.

Seed images used to create the development data are stored separately under `db/seeds/`.