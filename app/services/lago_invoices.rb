class LagoInvoices
  class << self
    # Expose the shared Lago client
    def client
      LAGO_CLIENT
    end

    # Fetch invoices for a customer
    def list(external_customer_id:, page: nil, per_page: nil)
      client.invoices.get_all(
        external_customer_id: external_customer_id,
        page: page,
        per_page: per_page
      )
    end
  end
end
