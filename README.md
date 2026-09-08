# Aafnai Coffee

Cafe management system for Aafnai Coffee.

## Requirements

- Ruby 3.4.2 (see `.ruby-version`)
- PostgreSQL 16 (Homebrew `postgresql@16`)
- Node.js is optional; it is not needed for the default toolchain and is
  only required if JS tooling that depends on it is added later.

## Setup

```sh
bin/setup
```

`bin/setup` runs `bundle install` and `bin/rails db:prepare`, which creates
and migrates the development and test databases.

## Running the app

```sh
bin/dev
```

Open http://localhost:3000.

## Tests

```sh
bin/rspec
```

Tests use RSpec. System specs run against Selenium with headless Chrome,
so a Chrome installation is required to run the full suite locally.

## Linting

```sh
bin/rubocop
```

## Security checks

```sh
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs linting, the test suite
against a PostgreSQL 16 service container, and security scans on every push
to `main` and on every pull request. Run the same checks locally with
`bin/ci`.

## Deployment

Not configured yet.