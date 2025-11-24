# Lago Billing Demo

A small Rails 8 demo that shows how to:
- Sign up a customer and create a subscription against Lago
- View a customer’s current subscription/plan
- View invoices for a customer
- Ingest and list usage events for billable metrics
- Browse a simple pricing page

## Stack
- Ruby 3.3.10
- Rails 8.1 + Propshaft
- SQLite (default)
- tailwindcss-rails / Tailwind 4
- `lago-ruby-client`

## Setup
1) Install dependencies
```sh
bundle install
```
```sh
npm install
```

2) Environment variables (see `config/initializers/lago.rb`)
```
LAGO_API_KEY=your_api_key
LAGO_BASE_URL=https://api.getlago.com   # or your self-hosted URL
```

3) Create DB
```sh
bin/rails db:setup
```

4) Build CSS (if you are not using the CDN placeholder)
```sh
npm run build:css
# or live reload: npm run build:css:watch
```

5) Run the app
```sh
bin/dev
```
This starts Rails, JS bundling, and CSS watching as defined in `Procfile.dev`.

## Key Flows
- **Pricing**: `/pricing` (also root) shows plans and links to signup.
- **Signup**: `/signups/new?plan_code=...` posts to `SignupsController#create`, which:
  - Creates a Lago customer (`LagoSignups.create_customer`)
  - Creates a subscription for that customer (`LagoSignups.create_subscription`)
  - Redirects to the customer show page
- **Customer**: `/customers/:external_id` shows the Lago customer, subscription, and plan (via `LagoCustomer`).
- **Invoices**: `/customers/:external_id/invoices` lists invoices (`InvoicesController#index` using `LagoInvoices`).
- **Usage Events**:
  - Button on the customer page posts a sample `ai_tokens` event (`CustomersController#ingest_event` -> `LagoEvents.send_event`).
  - `/customers/:external_id/events` lists events via `LagoEvents.list`.
- **Rake task**: ingest sample metered events
```sh
bin/rails "lago:events:ingest[CUSTOMER_ID,SUBSCRIPTION_ID]"
# or with env vars LAGO_CUSTOMER_ID / LAGO_SUBSCRIPTION_ID
```

## Tailwind
- Source: `app/assets/stylesheets/application.tailwind.css`
- Build output: `app/assets/builds/application.css` (and `.keep`)
- Build scripts: `npm run build:css` or `build:css:watch`
- A placeholder `app/assets/builds/tailwind.css` is present; regenerate locally if desired.

## Notes
- No automated test suite is present.
- If you change the billing metric codes, update the sample event payloads in `LagoEvents.send_event` and `lib/tasks/lago_events.rake`.
