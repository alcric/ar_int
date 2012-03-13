class DomainsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @domains = nil
    if current_user.admin? # Se sono amministratore mostro tutti i servizi attivi
      # Tento di ordinare l'elenco servizi
      sortable_column_order do |column, direction|
        if !column.nil? && !direction.nil?
          if direction == :asc
            @domains = Domain.asc(column)
          else
            @domains = Domain.desc(column)
          end
        end
      end

      # Se non è stato passato l'ordine, domains è vuoto
      if @domains.nil?
        # Utilizzo un ordinamento standard per nome e pagino i risultati
        @domains = Domain.desc(:name).page(params[:page])
      else
        # Services è presente e già ordinato, pagino i risultati
        @domains = @domains.page(params[:page])
      end

    else # Non sono amministratore, elenco solo i domini che mi appartengono

      # Tento di ordinare l'elenco domini
      sortable_column_order do |column, direction|
        if !column.nil? && !direction.nil?
          if direction == :asc
            @domains = current_user.domains.asc(column)
          else
            @domains = current_user.domains.desc(column)
          end
        end
      end

      # Se non è stato passato l'ordine, domain è vuoto
      if @domains.nil?
        # Utilizzo un ordinamento standard per tipo e pagino i risultati
        @domains = current_user.domains.desc(:name).page(params[:page])
      else
        # Domains è presente e già ordinato, pagino i risultati
        @domains = @domains.page(params[:page])
      end
    end
    # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
    respond_to do |format|
      format.html
      format.xml {render :xml => Domain.all.to_xml }
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

    @domain = current_user.domains.create(name: name, dom: params[:domain][:dom], tld: params[:domain][:tld])
    if @domain.save
      flash[:notice] = (t 'always_resolve.domain_create_success')
      redirect_to domains_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @domain.destroy
    flash[:notice] = (t 'always_resolve.domain_delete_success')

    respond_to do |format|
      format.html { redirect_to(domains_path) }
      format.xml  { head :ok }
    end
  end

end