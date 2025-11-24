require "lago-ruby-client"

LAGO_CLIENT = Lago::Api::Client.new(
  api_key: ENV.fetch("LAGO_API_KEY"),
  api_url: ENV.fetch("LAGO_BASE_URL", "http://localhost:3000")
)