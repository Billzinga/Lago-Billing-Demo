class LagoSignups
  class << self
    # Expose the underlying SDK client (from config/initializers/lago.rb)
    def client
      LAGO_CLIENT
    end

    # 1) Create customer in Lago
    def create_customer(external_id:, name:, email:)
      client.customers.create(
        external_id: external_id,
        name:        name,
        email:       email
      )
    end

    # 2) Create subscription linked to that customer
    def create_subscription(external_customer_id:, plan_code:, external_id:)
      client.subscriptions.create(
        external_customer_id: external_customer_id,
        plan_code:            plan_code,
        external_id:          external_id
      )
    end
  end
end
