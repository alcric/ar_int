class RecordsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @domain=Domain.find(params[:domain_id])
    if current_user != @domain.user
      redirect_to domains_path
    else
      @record = Record.find(params[:id])
      if current_user == @domain.user
        respond_to do |format|
          format.html
          format.xml  { render :xml => @record.to_xml }
        end
      end
    end
  end

  def new
    unless params[:tipo].nil?
      @tipo=params[:tipo]
    end

    @domain=Domain.find(params[:domain_id])
    @record=@domain.records.new
  end

  def create
    @domain=Domain.find(params[:domain_id])
    if current_user != @domain.user
      redirect_to domains_path
    else
      @record = @domain.records.create(terzo_livello: params[:record][:terzo_livello],
                                       tipo: params[:record][:tipo],
                                       dest: params[:record][:dest],
                                       priority: params[:record][:priority],
                                       port: params[:record][:port],
                                       weight: params[:record][:weight],)

      if @record.save
        flash[:notice] = (t 'always_resolve.record_create_success')

        respond_to do |format|
          format.html {redirect_to edit_domain_path(@domain)}
          format.xml  { head :ok }
        end
      else
        @tipo= params[:record][:tipo]
        respond_to do |format|
          format.html {render :action => 'new'}
          format.xml  { head :status => 500 }
        end
      end
    end
  end

  def update
    @domain=Domain.find(params[:domain_id])
    if current_user != @domain.user
      redirect_to domains_path
    else
      @record = Record.find(params[:id])
      if @record.update_attributes(terzo_livello: params[:record][:terzo_livello],
                                   tipo: params[:record][:tipo],
                                   dest: params[:record][:dest],
                                   priority: params[:record][:priority],
                                   port: params[:record][:port],
                                   weight: params[:record][:weight],)

        flash[:notice] = (t 'always_resolve.record_create_success')
        respond_to do |format|
          format.html { redirect_to edit_domain_path(@domain) }
          format.xml  { head :ok }
        end
      else
        @tipo= params[:record][:tipo]
        respond_to do |format|
          format.html { render :action => 'new' }
          format.xml  { head :status => 500 }
        end
      end
    end
  end

  def edit
    @record = Record.find(params[:id])
    @domain = Domain.find(params[:domain_id])
    if current_user != @domain.user
      redirect_to domains_path
    else
      @record.decode_name
      @record.decode_dest
      @tipo=@record.tipo
    end
  end

  def destroy
    @domain = Domain.find(params[:domain_id])
    if current_user != @domain.user
      redirect_to domains_path
    else
      @record = Record.find(params[:id])
      @record.destroy
      flash[:notice] = (t 'always_resolve.record_delete_success')
      respond_to do |format|
        format.html { redirect_to edit_domain_path(@domain) }
        format.xml  { head :ok }
      end
    end
  end

  def dyndns
    @domain=Domain.find(params[:domain_id])
    @record = Record.find(params[:id])
    if current_user == @domain.user
      @record.decode_name
      @record.decode_dest
      if @record.tipo=='A'
        if @record.update_attributes(dest: request.remote_ip)
          respond_to do |format|
            format.html
            format.xml  { render :xml => @record.to_xml }
          end
        else
          respond_to do |format|
            format.html
            format.xml  { head :status => 500 }
          end
        end
      end
    else
      redirect_to domains_path
    end
  end
end
