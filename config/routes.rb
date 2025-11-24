Rails.application.routes.draw do
  get  "/pricing", to: "pricing#index"

  root "pricing#index"

  resources :signups, only: [:new, :create]

  get "/customers/:external_id", to: "customers#show", as: :customer
  get  "/customers/:external_id/events", to: "customers#events",       as: :customer_events
  post "/customers/:external_id/events", to: "customers#ingest_event", as: :customer_ingest_event

  get "/customers/:external_id/invoices", to: "invoices#index", as: :customer_invoices
end
