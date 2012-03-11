class Service
  include Mongoid::Document
  field :type, :type => String
  field :activated, :type => Time
  field :expire, :type => Time

  embedded_in :user
  #belongs_to :domain, index: true

end
