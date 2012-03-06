AlwaysResolve::Application.routes.draw do

  devise_for :users
  resources  :users

  match 'services' => 'home#services'
  match 'aboutus' => 'home#aboutus'
  root :to => 'home#index'

end
