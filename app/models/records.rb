class Records
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => String
  field :content, :type => String
  field :ttl, :type => Integer
  field :prio, :type => Integer
end
