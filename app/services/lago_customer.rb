# app/services/lago_customer.rb
class LagoCustomer
  class << self
    # Expose the shared Lago API client
    def client
      LAGO_CLIENT
    end

    # Fetch a single customer by external ID
    def find_customer(external_id)
      client.customers.get(external_id)
    end

    # Fetch subscriptions linked to a customer
    def customer_subscriptions(external_id)
      client.subscriptions.get_all(external_customer_id: external_id)
    end
  end
end
