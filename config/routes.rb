AlwaysResolve::Application.routes.draw do

  resources   :services
  resources   :domains do
    resources :records do
      member do
        get 'dyndns'
      end
    end
  end

  devise_for :users
  resources  :users

  match 'products' => 'home#products'
  match 'aboutus' => 'home#aboutus'
  root :to => 'home#index'

end
