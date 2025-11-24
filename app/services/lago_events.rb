class LagoEvents
  class << self
    def client
      LAGO_CLIENT
    end

    def send_event(customer_id:, subscription_id:, metric_code:, properties:)
      event = {
        transaction_id:           "evt_#{customer_id}_#{Time.now.to_i}_#{rand(1000)}",
        external_customer_id:     customer_id,
        external_subscription_id: subscription_id,
        code:                     metric_code,
        # UNIX timestamp in seconds with millisecond precision (e.g., "1651240791.123")
        timestamp:                format("%.3f", Time.current.to_f),
        properties:               properties
      }

      client.events.create(event)
    end

    def list(customer_id:)
      client.events.get_all(external_customer_id: customer_id)
    end
  end
end
