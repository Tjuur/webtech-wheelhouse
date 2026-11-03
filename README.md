# Wheelhouse

Wheelhouse is a Ruby on Rails application for a neighbourhood bicycle repair shop. It manages customers, bicycles, repairs, services, staff, intake photographs, and repair diagnoses. A versioned JSON API exposes service prices publicly and repair information through Bearer token authentication.

## Documentation

- [User Stories](docs/user-stories.md)
- [Domain Model](docs/domain-model.md)
- [Design Decisions](docs/decisions.md)
- [Wireframes](docs/wireframes.md)
- [API Reference](docs/api.md)
- [Authorization and Permissions](docs/permissions.md)

The API reference documents endpoints, authentication, response formats, errors, and CORS restrictions. The permissions document describes role-specific authorization and record-level access rules.

## Prerequisites

- Ruby 4.0.4
- Rails 8.1.4
- Node.js 26.1.0
- Yarn
- PostgreSQL
- libvips

PostgreSQL must be running locally, and the configured database role must be able to create databases.

Install libvips on macOS:

```bash
brew install vips
```

On Ubuntu or Debian:

```bash
sudo apt update
sudo apt install libvips
```

Verify installation:

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

```bash
bundle install
yarn install
```

### 3. Configure Rails credentials

Wheelhouse stores the API Bearer token in Rails encrypted credentials. Create or edit the credentials file:

```bash
EDITOR="nano" bin/rails credentials:edit
```

Add:

```yaml
api_token: YOUR_SECRET_TOKEN
```

Generate a token using:

```bash
bin/rails secret
```

Use the generated value in place of `YOUR_SECRET_TOKEN`. Never commit the token or `config/master.key`. If an encrypted credentials file already exists, its matching master key is required to decrypt it.

### 4. Set up the database

With PostgreSQL running:

```bash
bin/rails db:setup
```

This creates the database, loads the schema, and populates development data. For an existing database, apply new migrations and run seeds separately:

```bash
bin/rails db:migrate
bin/rails db:seed
```

Seeds include services, staff, user accounts, customers, bicycles, repairs, repair service lines, diagnoses, and intake photographs. The seeds are idempotent: rerunning them does not delete existing application records or reset existing user passwords. Repairs created by the seed script use stable `seed_key` identifiers; older matching demo repairs can be associated with those identifiers when an unambiguous match exists.

### 5. Start the application

```bash
bin/dev
```

The application is available at `http://localhost:3000`.

| Page | Path |
|---|---|
| Home | `/` |
| Repairs | `/repairs` |
| Services | `/services` |
| Customers | `/customers` |
| Bikes | `/bikes` |
| Staff | `/staff` |
| Sign in | `/session/new` |
| Register | `/registration/new` |
| Password reset | `/passwords/new` |

The service catalog and authentication pages are publicly accessible. Other HTML resources require authentication and may have additional role-based restrictions.

## Authentication and Authorization

Wheelhouse uses Rails' native authentication system for browser sessions, registration, and password recovery. Passwords use `has_secure_password` with BCrypt and must be at least 10 characters long.

Pundit enforces authorization through policies for customers, bikes, repairs, services, and staff. Policies deny access unless a permission is explicitly granted. Collection actions use policy scopes, while individual actions use record-level authorization. Authenticated users who lack permission receive HTTP `403 Forbidden`; unauthenticated visitors attempting to access protected pages are redirected to sign in.

### Roles and permissions

| Resource | Owner | Counter | Mechanic |
|---|---|---|---|
| Customers | Full access | View, create, update | No access |
| Bikes | Full access | View, create, update | No access |
| Repairs | Full access | View, create, update unless picked up | View assigned; update assigned unless picked up |
| Services | Full access | Read only | Read only |
| Staff | Full access | Read only | Read only |

The service catalog's index and show pages are also public. Mechanics cannot create or delete repairs, access unassigned repairs, or access repairs assigned to another staff member. A mechanic without an associated staff record cannot access repairs through mechanic-specific permissions. Mechanic repair updates are limited to `status`, `diagnosis`, and `intake_photos`.

Authorization is enforced on the server, independently of whether a navigation link, button, or form field is visible. For the complete action-level permissions matrix and implementation details, see [Authorization and Permissions](docs/permissions.md) and [Design Decisions](docs/decisions.md).

### Registration and sessions

New users can register at `/registration/new` using a unique email address, a password of at least 10 characters, and password confirmation. Email addresses are normalized to lowercase. Newly registered users receive the `counter` role without a staff association; registration does not permit selecting a role or staff member.

Successful registration starts a session and queues a welcome email. After signing in, users are redirected to their originally requested page when applicable. The navigation bar displays the signed-in user's staff name or email address, role, and sign-out action. Signing out ends the session.

### Development accounts

Running `bin/rails db:seed` creates these accounts if they do not already exist:

| Email | Password | Role | Staff |
|---|---|---|---|
| `hank@wheelhouse.cl` | `HankPassword123!` | Owner | Hank Schrader |
| `walter@wheelhouse.cl` | `WalterPassword123!` | Mechanic | Walter White |
| `jessie@wheelhouse.cl` | `JessiePassword123!` | Mechanic | Jessie Pinkman |
| `scarlett@wheelhouse.cl` | `ScarlettPassword123!` | Counter | Scarlett Johansson |
| `guest@wheelhouse.cl` | `GuestPassword123!` | Counter | None |

These credentials are for local development and testing only. Existing passwords are not overwritten by subsequent seed runs. Demo repairs include assigned and unassigned work orders, multiple lifecycle states, completed and unfinished repairs, repair services, diagnoses, and intake photos.

### Repair reception tracking

New repairs record the authenticated user who received them through `Current.user`. This association is assigned server-side and cannot be modified through submitted repair parameters. The receiving user's staff name or email address appears in repair listings and detail pages when available. Older repairs without a recorded receiver remain valid.

### Password recovery

Users can request a reset at `/passwords/new`. If the account exists, Wheelhouse queues a reset email; the confirmation message does not reveal whether the submitted email is registered. Reset links expire after 15 minutes and become invalid after the password changes.

In development, emails are written to `tmp/sent_emails/`, without requiring an external SMTP service. To test a reset, submit an existing email address, open the generated message, follow its local reset link, and enter a new password. Welcome and password-reset messages have HTML and plain-text versions. Development uses an asynchronous Active Job adapter for email delivery.

Mailer previews are available at `/rails/mailers`, including `/rails/mailers/welcome_mailer/welcome`.

## JSON API

The versioned API is available under `http://localhost:3000/api/v1`. API controllers use `ActionController::API` and are separate from the HTML controllers. The API retains its Bearer token authentication independently of browser sessions and Pundit-based HTML authorization.

| Method | Endpoint | Authentication | Description |
|---|---|---|---|
| GET | `/api/v1/services` | Public | List services and prices |
| GET | `/api/v1/services/:id` | Public | Retrieve one service |
| POST | `/api/v1/services` | Bearer token | Create a service |
| GET | `/api/v1/repairs` | Bearer token | List repairs |
| GET | `/api/v1/repairs/:id` | Bearer token | Retrieve one repair |

### Public service requests

```bash
curl -i http://localhost:3000/api/v1/services
curl -i http://localhost:3000/api/v1/services/23
```

An example service response is:

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

The values are illustrative. Prices are serialized as decimal strings, and `repair_count` is calculated from associated repair service records.

### Authenticated API requests

Store your local API token in a shell variable:

```bash
export WHEELHOUSE_TOKEN="YOUR_SECRET_TOKEN"
```

Retrieve repairs:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  http://localhost:3000/api/v1/repairs
```

Retrieve one repair:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  http://localhost:3000/api/v1/repairs/1
```

Filter by status:

```bash
curl -i \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  "http://localhost:3000/api/v1/repairs?state=Ready"
```

The `state` parameter must match a valid repair status. Invalid values return HTTP `400 Bad Request`.

### Create a service

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

Successful creation returns HTTP `201 Created`, the new service as JSON, and a `Location` header. Invalid attributes return `422 Unprocessable Entity`; missing service attributes return `400 Bad Request`.

### API error responses

Errors use this structure:

```json
{
  "errors": [
    "Error description"
  ]
}
```

| Status | Meaning |
|---|---|
| 200 | Successful GET request |
| 201 | Service created |
| 400 | Invalid request or parameters |
| 401 | Missing or invalid API authentication |
| 404 | Record not found |
| 422 | Validation failure |

For complete request and response examples, see [API Reference](docs/api.md).

## API Security and CORS

Protected API endpoints require an `Authorization: Bearer ...` header. The expected token is stored in Rails encrypted credentials and compared using a timing-safe method. API repair responses do not expose customer phone numbers or internal foreign keys.

Cross-origin browser access is restricted to:

- `https://tjuur.github.io`
- `http://localhost:8000`

CORS is enabled only for public service GET endpoints. Protected repair endpoints and service creation are not exposed through CORS. Command-line tools such as `curl` are not subject to browser CORS restrictions.

## Personal Website Integration

The public Wheelhouse service catalog is integrated into a personal website:

- Website: `https://tjuur.github.io/webtech-lab-01/`
- Repository: `https://github.com/Tjuur/webtech-lab-01`

The website uses the Fetch API to retrieve service names, prices, and repair counts. It supports loading and error states, service lookup by ID, and dynamically generated service rows. Responses are handled with `async`/`await`, `response.ok`, and safe DOM methods such as `createElement()` and `textContent()`.

### Local integration testing

Start Wheelhouse:

```bash
cd webtech-wheelhouse
bin/dev
```

In a separate terminal, start a server from the personal website repository:

```bash
cd webtech-lab-01
python3 -m http.server 8000
```

Open `http://localhost:8000` and navigate to the Wheelhouse section. The personal website requests the API at `http://localhost:3000`, so the Rails application must be running locally. The GitHub Pages integration is intended for local demonstration; the API is not publicly deployed.

## Uploaded Files

Development uploads use Active Storage and are stored in `storage/`. Generated files and uploaded user content should not be committed to Git. Source images used for development seeds are kept under `db/seeds/`.

## Testing and Code Quality

Run the full test suite:

```bash
bin/rails test
```

Run the welcome mailer test:

```bash
bin/rails test test/mailers/welcome_mailer_test.rb
```

Verify Rails autoloading:

```bash
bin/rails zeitwerk:check
```

Check Ruby formatting and lint rules:

```bash
bundle exec rubocop
```

Run the security scan:

```bash
bundle exec brakeman -q
```

The authorization test suite includes Pundit policy tests and HTTP integration tests for role permissions, repair assignments, completed repair restrictions, public access, and unauthorized requests.

At the completion of Lab 12, the local checks reported 56 tests, 213 assertions, no test failures or errors, no RuboCop offenses, and no Brakeman security warnings.
