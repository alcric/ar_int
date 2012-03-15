class PaypalExpressController < ApplicationController
  before_filter :assigns_gateway
  include ActiveMerchant::Billing
  include PaypalExpressHelper

  def checkout
    #total_as_cents, setup_purchase_params = get_setup_purchase_params @cart, request
    setup_response = @gateway.setup_authorization(50,
                                                  :description => 'Descrizione',
                                                  :return_url => url_for(:controller => 'paypal_express', :action => 'checkout'),
                                                  :cancel_return_url => services_path
    )
    redirect_to @gateway.redirect_url_for(setup_response.token)

  end

  def subscribe
    token = params[:token]
    # here we authorize the amount first before charging it
    authorize_response = @gateway.authorize(50,
    :ip       => request.remote_ip,
    :payer_id => params[:PayerID],
    :token    => params[:token]
    )

    if authorize_response.success?
      # period can be Day, Week, Month, Year, etc...
      profile_response = @gateway.create_profile(params[:token],
        :description => "Descizione",
        :start_date => Date.today + 1.month,
        :period => 'Month',
        :frequency => 1,
        :amount => 50,
        :auto_bill_outstanding => true)

      if profile_response.success?
        # capture the payment
        @gateway.capture(money, authorize_response.authorization)

        # save paypal_profile_id to edit the subscription later
        # The profile_id is stored in: profile_response.params["profile_id"]
      else
        # void the transaction
        @gateway.void(authorize_response.authorization)
        flash[:alert] = profile_response.message
        #redirect_to checkout_path
      end
    end
  end

  private

  def assigns_gateway
    @gateway ||= ActiveMerchant::Billing::PaypalRecurringGateway.new(
        :login     => PAYPAL_LOGIN,
        :password  => PAYPAL_PASSWORD,
        :signature => PAYPAL_SIGNATURE,
    )
  end
end
