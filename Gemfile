source 'https://rubygems.org'

# Rails, il framework
gem 'rails', '3.2.1'

# gemme per il javascript
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# rspec & co. per i test (faremo...)
group :development do
  gem 'rspec-rails', '~> 2.8.1'
end

group :test do
  gem 'rspec-rails', '~> 2.8.1'
  gem 'database_cleaner', '~> 0.7.1'
  gem 'mongoid-rspec', '~> 1.4.4'
  gem 'factory_girl_rails', '~> 1.7.0'
  gem 'cucumber-rails', '~> 1.3.0'
  gem 'capybara', '~> 1.1.2'
  gem 'launchy', '~> 2.0.5'
end

# Mongoid per la gestione del database MongoDB
gem 'bson_ext', '~> 1.6.0'
gem 'mongoid', '~> 2.4.5'

# Devise per la gestione delle autenticazioni
gem 'devise', '~> 2.0.4'
gem 'devise-i18n'

# Activemerchant per l'interfacciamento con Paypal; uso il fork di vantran che gestisce i pagamenti ricorrenti
#gem 'activemerchant', :require => 'active_merchant'
gem 'activemerchant', :git => 'git://github.com/vantran/active_merchant.git'

# kaminari è una gemma per il paging dei dati compatibile con mongoid
gem 'kaminari'

# Gravatar per l'avatar utente
gem 'gravatar_image_tag'

# i18n per la localizzazione e localeapp per la gestione delle traduzioni on-line
gem 'i18n'
gem 'localeapp'

# country_select permette di creare un select nel form con l'elenco di tutti i paesi
gem 'country_select'

# sistema semplificato per creare i form
gem 'simple_form'

#gem 'show_for'

# css e javascript dell'interfaccia
gem 'twitter-bootstrap-rails'

# gestisce l'ordinamento delle colonne di una tabella
gem 'handles_sortable_columns'

# contiene l'elenco di tutti i tld
gem 'public_suffix'

# capistrano per il deploy automatico sugli application server, unicorn è il web server in produzione
# per aggiornare i server, commit su github e poi cap deploy; cap deploy:restart
gem 'capistrano'
gem 'unicorn'

# permette di gestire il setting dei parametri attraverso un file yaml
gem 'settingslogic'

# funzione per la gestione delle url
gem 'uri-handler', :require => 'uri-handler'

# whois per le informazioni dominio
gem 'whois'

# Net-Dns per la verifica dei record
gem 'net-dns'

# gemme per il controllo del server
gem 'net-ping'
#gem 'net-smtp'
#gem 'net-http'
#gem 'net-ftp'