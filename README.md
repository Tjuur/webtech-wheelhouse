# Wheelhouse

Wheelhouse is a web application for a neighbourhood bicycle repair shop. The application provides public information about the shop, including its services and prices, visiting information, and information about the shop.

## Documentation

The specification and design documents from Lab 3 are available here:

- [User Stories](docs/user-stories.md)
- [Domain Model](docs/domain-model.md)
- [Decisions](docs/decisions.md)
- [Wireframes](docs/wireframes.md)

## Prerequisites

Before running Wheelhouse, make sure the following are installed:

- Ruby 4.0.4
- Rails 8.0
- Node.js 26.1.0
- Yarn
- PostgreSQL

PostgreSQL must be running locally, and the PostgreSQL role used by the application must have permission to create databases.

## Setup

Clone the repository:

```bash
git clone https://github.com/Tjuur/webtech-wheelhouse.git
cd webtech-wheelhouse
```

Install dependencies:

```bash
bundle install
yarn install
```

Create the database, load the schema, and seed the development data:

```bash
bin/rails db:setup
```

Run the application:

```bash
bin/dev
```

Then open:

```text
http://localhost:3000
```

The services page is available at:

```text
http://localhost:3000/services
```
