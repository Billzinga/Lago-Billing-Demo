namespace :lago do
  namespace :events do
    desc "Ingest sample metered events for a customer + subscription. Usage: bin/rails \"lago:events:ingest[CUSTOMER_ID,SUB_ID]\""
    task :ingest, [:external_customer_id, :external_subscription_id] => :environment do |_t, args|
      customer_id     = args[:external_customer_id] || ENV["LAGO_CUSTOMER_ID"]
      subscription_id = args[:external_subscription_id] || ENV["LAGO_SUBSCRIPTION_ID"]

      unless customer_id && subscription_id
        abort "external_customer_id and external_subscription_id are required. Pass as task args or env vars."
      end

      puts "Sending usage events for customer=#{customer_id}, subscription=#{subscription_id}..."

      events = [
        {
          metric_code: "ai_tokens",
          properties:  { tokens: 50_000 }
        },
        {
          metric_code: "storage_gb",
          properties:  { gb: 5 }
        }
      ]

      events.each do |event|
        LagoEvents.send_event(
          customer_id:     customer_id,
          subscription_id: subscription_id,
          metric_code:     event[:metric_code],
          properties:      event[:properties]
        )
        puts "  ✔ sent #{event[:metric_code]} with #{event[:properties].inspect}"
      end

      puts "Done."
    end
  end
end
