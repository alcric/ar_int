class DomainsController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user.admin? # Se sono amministratore mostro tutti i servizi attivi
      @domains = sort_and_paginate(Domain.all)
    else # Non sono amministratore, elenco solo i domini che mi appartengono
      @domains = sort_and_paginate(current_user.domains.all)
    end

    # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
    respond_to do |format|
      format.html
      format.xml {render :xml => current_user.domains.all.to_xml }
    end
  end

  def show
  end

  def new
    @domain = Domain.new
    @public_suffix = '['
    f = File.open("public/public-suffix.txt", "r")
    f.each_line do|line|
      if (!line.to_s.match(/^\/\//)) && (!line.to_s.strip.empty?)
        if @public_suffix != '['
          @public_suffix.concat (',')
        end

        @public_suffix.concat ('"' + line.to_s.strip + '"')
      end
    end
    @public_suffix.concat(']')
  end

  def edit
  end

  def create
    if !params[:domain][:dom].to_s.strip.nil? && !params[:domain][:tld].to_s.strip.nil?
      name = params[:domain][:dom].to_s + "." + params[:domain][:tld]
    end
    if current_user.admin?
      @domain = current_user.domains.create(name: name, dom: params[:domain][:dom], tld: params[:domain][:tld])
    else
      if current_user.services.where(service_type: 'service1', domain_id: nil).count > 0
        service = current_user.services.where(service_type: 'service1', domain_id: nil).first
        @domain = current_user.domains.create(name: name, dom: params[:domain][:dom], tld: params[:domain][:tld])
        @domain.services << service
      end
    end

    if @domain.save
      flash[:notice] = (t 'always_resolve.domain_create_success')
      redirect_to domains_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @domain.services=nil
    @domain.destroy
    flash[:notice] = (t 'always_resolve.domain_delete_success')

    respond_to do |format|
      format.html { redirect_to(domains_path) }
      format.xml  { head :ok }
    end
  end

end