class CustomersController < ApplicationController
  def show
    external_id = params[:external_id]

    # 1) Fetch the Lago customer
    customer_response = LagoCustomer.find_customer(external_id)
    @customer = unwrap(customer_response, :customer) || customer_response
    @customer_name = extract(@customer, :name)
    @customer_external_id = extract(@customer, :external_id)

    # 2) Fetch subscriptions for this customer
    subs_response = LagoCustomer.customer_subscriptions(external_id)
    @subscription =
      if subs_response.respond_to?(:subscriptions)
        subs_response.subscriptions.first
      elsif subs_response.is_a?(Hash)
        subs_response["subscriptions"]&.first || subs_response[:subscriptions]&.first
      elsif subs_response.respond_to?(:first)
        subs_response.first
      end
    @subscription_plan_code = extract(@subscription, :plan_code)
    @subscription_status = extract(@subscription, :status)
    @subscription_external_id = extract(@subscription, :external_id)

    # 3) Optionally fetch the plan details
    if @subscription_plan_code.present?
      plan_response = LagoCustomer.client.plans.get(@subscription_plan_code)
      @plan = unwrap(plan_response, :plan)
      @plan_name = extract(@plan, :name)
    end
  rescue Lago::Api::HttpError => e
    Rails.logger.error("Lago error in CustomersController#show: #{e.message}")
    redirect_to pricing_path, alert: "Could not load customer from Lago."
  end

  def ingest_event
    external_id = params[:external_id]
    subs_response = LagoCustomer.customer_subscriptions(external_id)

    subscription =
      if subs_response.respond_to?(:subscriptions)
        subs_response.subscriptions.first
      elsif subs_response.is_a?(Hash)
        subs_response["subscriptions"]&.first || subs_response[:subscriptions]&.first
      elsif subs_response.respond_to?(:first)
        subs_response.first
      end

    unless subscription
      return redirect_to customer_path(external_id), alert: "No subscription found to ingest usage."
    end

    subscription_id = extract(subscription, :external_id)

    LagoEvents.send_event(
      customer_id:     external_id,
      subscription_id: subscription_id,
      metric_code:     "demo-usage",
      properties:      1000
    )

    redirect_to customer_path(external_id), notice: "Usage event ingested."
  rescue => e
    Rails.logger.error("Error ingesting event: #{e.message}")
    redirect_to customer_path(external_id), alert: "Could not ingest event."
  end

  def events
    external_id = params[:external_id]
    response = LagoEvents.list(customer_id: external_id)

    @events =
      if response.respond_to?(:events)
        response.events
      else
        response
      end
  rescue => e
    Rails.logger.error("Error fetching events: #{e.message}")
    @error  = e
    @events = []
  end

  private

  # Helper to pull the nested object out of SDK responses
  def unwrap(response, key)
    return unless response

    if response.respond_to?(key)
      response.public_send(key)
    elsif response.respond_to?(:[])
      response[key.to_s] || response[key]
    end
  end

  # Helper to safely read values from SDK objects or hashes
  def extract(obj, key)
    return unless obj

    if obj.respond_to?(key)
      obj.public_send(key)
    elsif obj.respond_to?(:[])
      obj[key.to_s] || obj[key]
    end
  end
end
