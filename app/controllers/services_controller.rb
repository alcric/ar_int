class ServicesController < ApplicationController
  include ActiveMerchant::Billing

  before_filter :authenticate_user!, :assigns_gateway, :setup_service

  def index
    if current_user.admin? # Se sono amministratore mostro tutti i servizi attivi
      @services = sort_and_paginate(Service.all)
    else # Non sono amministratore, elenco solo i servizi che mi appartengono
      @services = sort_and_paginate(current_user.services.all)
    end
    # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
    respond_to do |format|
      format.html
      format.xml {render :xml => current_user.services.all.to_xml }
    end
  end

  def show
    @service = Service.find(params[:id])
    if @service.profile_id == 'free'
      @pay_data = nil
    else
      @pay_data = @gateway.get_profile_details(@service.profile_id)
    end
  end

  def edit
  end

  def new
    @service = Service.new
  end

  def create
    if current_user.admin?
      user=User.find(params[:service][:user])
      @service = user.services.create(service_type: params[:service][:service_type], activated: Date.today, expire: Date.today + 25.years, profile_id: 'free')
      if @service.save!
        flash[:notice] = (t 'always_resolve.service_create_success')
        redirect_to services_path
      else
        #flash[:alert] = @service.message
        redirect new_service_url
      end
    else
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        :first_name => params[:service][:first_name],
        :last_name  => params[:service][:last_name],
        :month      => params[:service]['expire(2i)'],
        :year       => params[:service]['expire(1i)'],
        :type       => params[:service][:type],
        :number     => params[:service][:number]
      )

      response = @gateway.create_profile( nil,
                                          :credit_card => credit_card,
                                          :description => (t 'always_resolve.' + params[:service][:service_type]),
                                          :start_date => Date.today + 1.month,
                                          :period => 'Month',
                                          :frequency => 1,
                                          :amount => @price[params[:service][:service_type]].to_i * 100,
                                          :initial_amount => @price[params[:service][:service_type]].to_i * 100,
                                          :auto_bill_outstanding => true,
                                          :currency => 'EUR'
      )

      if response.success?
        @service = current_user.services.create(service_type: params[:service][:service_type], activated: Date.today, expire: Date.today + 1.month, profile_id: response.params["profile_id"])
        if @service.save!
          flash[:notice] = (t 'always_resolve.service_create_success')
          redirect_to services_path
        else
          #flash[:alert] = @service.message
          redirect new_service_url
        end
      else
        flash[:alert] = response.message
        redirect_to new_service_url
      end
    end

  end

  def destroy
    @service = Service.find(params[:id])
    # Elimino il profilo in PayPal
    unless @service.profile_id == 'free'
      response = @gateway.cancel_profile(@service.profile_id)
      success =  response.success?
    else
      success = true
    end

    if success
      if @service.service_type == 'service1'
        # sto cancellando un servizio dominio
        domain=@service.domain
        # libero tutti i servizi legati al dominio
        domain.services=nil
        # cancello il dominio
        domain.destroy
        # cancello il servicio
        @service.destroy
        flash[:notice] = (t 'always_resolve.service_delete_success')
      end
    end

    respond_to do |format|
      format.html { redirect_to(services_path) }
      format.xml  { head :ok }
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

  def setup_service
    @price= Hash.new

    @price['service1'] = Setting.service1.price
    @price['service2'] = Setting.service2.price
    @price['service3'] = Setting.service3.price
    @price['service4'] = Setting.service4.price
  end
end
