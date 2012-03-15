class Domain
  include Mongoid::Document
  field :name, :type => String
  attr_accessible :dom, :tld, :name
  attr_accessor :dom, :tld

  index :name, unique: true
  index 'records.name'

  belongs_to :user
  has_many :records
  has_many :services

  validates_presence_of :dom, :tld
  validates_uniqueness_of :name

end
