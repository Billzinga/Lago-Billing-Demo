class InvoicesController < ApplicationController
  def index
    external_id = params[:external_id]

    # lago-ruby-client exposes top-level resources via the client
    response = LagoInvoices.list(external_customer_id: external_id)

    # Response is typically an object with an `invoices` field
    @invoices =
      if response.respond_to?(:invoices)
        response.invoices
      else
        response # fallback – you can inspect in the console
      end
  rescue => e
    Rails.logger.error("Error fetching invoices from Lago: #{e.message}")
    @error    = e
    @invoices = []
  end
end
