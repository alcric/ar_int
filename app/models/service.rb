class Service
  include Mongoid::Document
  field :service_type, :type => String
  field :profile, :type => String
  field :activated, :type => Time
  field :expire, :type => Time

  attr_accessor :first_name, :last_name, :type, :number, :month, :year, :verification_value

  belongs_to :user
  belongs_to :domain

end
