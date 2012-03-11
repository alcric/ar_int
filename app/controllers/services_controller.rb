class ServicesController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user.admin? # Se sono amministratore mostro tutti i servizi attivi
      # Tento di ordinare l'elenco servizi
      sortable_column_order do |column, direction|
        puts column
        puts direction
        @services = Service.sort_by(column, direction)
      end

      # Se non è stato passato l'ordine, user è vuoto
      if @services.nil?
        # Utilizzo un ordinamento standard per tipo e pagino i risultati
        @services = Service.desc(:type).page(params[:page])
      else
        # Services è presente e già ordinato, pagino i risultati
        @services = @services.page(params[:page])
      end
    else # Non sono amministratore, elenco solo i serizi che mi appartengono
      # Tento di ordinare l'elenco servizi
      sortable_column_order do |column, direction|
        puts column
        puts direction
        @services = Service.where(:user_id => current_user).sort_by(column, direction)
      end

      # Se non è stato passato l'ordine, user è vuoto
      if @services.nil?
        # Utilizzo un ordinamento standard per tipo e pagino i risultati
        @services = Service.where(:user_id => current_user).desc(:type).page(params[:page])
      else
        # Services è presente e già ordinato, pagino i risultati
        @services = @services.page(params[:page])
      end
    end
    # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
    respond_to do |format|
      format.html
      format.xml {render :xml => Service.all.to_xml }
    end
  end

  def show
  end

  def edit
  end

  def new
  end
end
