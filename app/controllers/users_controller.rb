class UsersController < ApplicationController
  before_filter :authenticate_user!
  # curl http://www.alwaysresolve.com:3000/users -H "Accept: application/xml" --user admin@tglobal.it:password
  def index
    # Controllo se l'ultente è amministratore
    if current_user.admin?
      # Tento di ordinare l'elenco utenti'
      sortable_column_order do |column, direction|
        if !column.nil? && !direction.nil?
          if direction == :asc
            @users = User.asc(column)
          else
            @users = User.desc(column)
          end
        end
      end

      # Se non è stato passato l'ordine, user è vuoto
      if @users.nil?
        # Utilizzo un ordinamento standard per cognome e pagino i risultati
        @users = User.desc(:surname).page(params[:page])
      else
        # User è presente e già ordinato, pagino i risultati
        @users = @users.page(params[:page])
      end

      # Controllo il tipo di formato richiesto per rispondere con XML in caso di query
      respond_to do |format|
        format.html
        format.xml {render :xml => User.all.to_xml }
      end
    else
      redirect_to root_path
    end
  end

  def show
    if current_user.admin?
      @user = User.find(params[:id])
      respond_to do |format|
        format.html
        format.xml {render :xml => @user }
      end
    else
      redirect_to root_path
    end
  end

  def edit
    if current_user.admin?
      @user = User.find(params[:id])
    else
      redirect_to root_path
    end
  end

  def update
    if current_user.admin?
      @user = User.find(params[:id])

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to(@user, :notice => (t 'always_resolve.user_was_successfully_updated')) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    if current_user.admin?
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      end
    else
      redirect_to root_path
    end
  end
end
