class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  handles_sortable_columns do |conf|
    conf.sort_param = "sort_by"
  end

  def set_locale
    locale = extract_locale_from_subdomain || 'en'
    if locale == 'en'
      I18n.locale = 'en-US'
    else
      I18n.locale = locale
    end
  end

  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
  end

  def sort_and_paginate(data)
    # Tento di ordinare l'elenco servizi
    sortable_column_order do |column, direction|
      if !column.nil? && !direction.nil?
        if direction == :asc
          data = data.asc(column)
        else
          data = data.desc(column)
        end
      end
    end

    data = data.page(params[:page])
  end
end
