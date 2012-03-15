AlwaysResolve::Application.routes.draw do
  get "paypal_express/checkout"
  get "paypal_express/subscribe"

  resources   :services
  resources   :domains

  devise_for :users
  resources  :users

  match 'products' => 'home#products'
  match 'aboutus' => 'home#aboutus'
  root :to => 'home#index'

end
