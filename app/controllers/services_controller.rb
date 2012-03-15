class ServicesController < ApplicationController
  include ActiveMerchant::Billing

  before_filter :authenticate_user!

  def index
    if current_user.admin? # Se sono amministratore mostro tutti i servizi attivi
      # Tento di ordinare l'elenco servizi
      sortable_column_order do |column, direction|
        if !column.nil? && !direction.nil?
          if direction == :asc
            @services = Service.asc(column)
          else
            @services = Service.desc(column)
          end
        end
      end

      # Se non è stato passato l'ordine, user è vuoto
      if @services.nil?
        # Utilizzo un ordinamento standard per tipo e pagino i risultati
        @services = Service.desc(:type).page(params[:page])
      else
        # Services è presente e già ordinato, pagino i risultati
        @services = @services.page(params[:page])
      end

      # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
      respond_to do |format|
        format.html
        format.xml {render :xml => Service.all.to_xml }
      end
    else # Non sono amministratore, elenco solo i servizi che mi appartengono
      # Tento di ordinare l'elenco servizi
      sortable_column_order do |column, direction|
        if !column.nil? && !direction.nil?
          if direction == :asc
            @services = current_user.services.asc(column)
          else
            @services = current_user.services.desc(column)
          end
        end
      end

      # Se non è stato passato l'ordine, user è vuoto
      if @services.nil?
        # Utilizzo un ordinamento standard per tipo e pagino i risultati
        @services = current_user.services.desc(:type).page(params[:page])
      else
        # Services è presente e già ordinato, pagino i risultati
        @services = @services.page(params[:page])
      end
      # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
      respond_to do |format|
        format.html
        format.xml {render :xml => current_user.services.all.to_xml }
      end

    end
  end

  def show
  end

  def edit
  end

  def new
    @service = Service.new
  end

end
