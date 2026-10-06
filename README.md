# Wheelhouse

Wheelhouse is a web application for a neighbourhood bicycle repair shop. The application manages customers, bikes, repairs, services, staff, intake photos, and repair diagnoses.

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

## Setup

Clone the repository:

```bash
git clone https://github.com/Tjuur/webtech-wheelhouse.git
cd webtech-wheelhouse
```

Install the Ruby and JavaScript dependencies:

```bash
bundle install
yarn install
```

Create the database, run the migrations, and load the development seed data:

```bash
bin/rails db:setup
```

The seed data includes customers, bikes, staff, services, repairs, diagnoses, and intake photos.

Start the application:

```bash
bin/dev
```

Then open:

```text
http://localhost:3000
```

The repairs page is available at:

```text
http://localhost:3000/repairs
```

The seeded repairs page displays intake-photo thumbnails and diagnosis excerpts.

The services page is available at:

```text
http://localhost:3000/services
```

## Uploaded Files

In development, uploaded files are stored locally in the `storage/` directory using Active Storage.

Files uploaded while using the application should not be committed to Git. Seed images used to create the development data are stored separately under `db/seeds/`.