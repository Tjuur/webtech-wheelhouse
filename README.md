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
- npm
- PostgreSQL

PostgreSQL must be running locally, and the PostgreSQL user must have permission to create databases.

## Setup

Clone the repository:

```bash
git clone https://github.com/Tjuur/webtech-wheelhouse.git
cd webtech-wheelhouse
```

Install dependencies and create:

```bash
bundle install
npm install
bin/rails db:create
```

Run 

```bash
bin/dev
```