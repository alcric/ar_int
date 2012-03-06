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
    logger.info (locale)
  end

  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
  end
end
