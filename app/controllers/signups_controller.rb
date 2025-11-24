# app/controllers/signups_controller.rb
class SignupsController < ApplicationController
  def new
    @plan_code = params[:plan_code] || "acme-sub"
  end

  def create

    # 1) Create customer
    LagoSignups.create_customer(
      external_id: params[:external_id],
      name:        params[:name],
      email:       params[:email]
    )

    # 2) Create subscription for that customer
    LagoSignups.create_subscription(
      external_id:            "sub_#{SecureRandom.hex(4)}", # unique subscription ID
      plan_code:              params[:plan_code].presence || "acme-sub",
      external_customer_id:   params[:external_id] # link to the customer we just created
    )

    redirect_to customer_path(params[:external_id]), notice: "Signed up successfully!"
  rescue Lago::Api::HttpError => e
    Rails.logger.error("Lago error: #{e.message}")
    redirect_to new_signup_path(plan_code: params[:plan_code]),
                alert: "Billing setup failed. Please try again."
  end
end
