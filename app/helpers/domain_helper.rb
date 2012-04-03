module DomainHelper
  def hasFreeService?(user,tipo)
    if tipo=='all'
      return user.services.all.count > 0
    else
      return user.services.where(:service_type => tipo).count > 0
    end
  end
end
