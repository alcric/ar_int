class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :name,               :type => String, :null => false, :default => ""
  field :surname,            :type => String, :null => false, :default => ""
  field :company,            :type => String, :null => false, :default => ""
  field :address1,           :type => String, :null => false, :default => ""
  field :address2,           :type => String, :null => false, :default => ""
  field :city,               :type => String, :null => false, :default => ""
  field :zip,                :type => String, :null => false, :default => ""
  field :state,              :type => String, :null => false, :default => ""
  field :country,            :type => String, :null => false, :default => ""
  field :vat,                :type => String, :null => false, :default => ""
  field :fiscal_code,        :type => String, :null => false, :default => ""
  field :telephone,          :type => String, :null => false, :default => ""
  field :fax,                :type => String, :null => false, :default => ""
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""
  field :admin,              :type => Boolean,:null => false, :default => false

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Encryptable
  field :password_salt, :type => String

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  index :email, unique: true
  index 'services.type'

  has_many :domains
  embeds_many :services

  validates_presence_of :name, :surname, :address1, :city, :zip, :country, :state, :fiscal_code, :email
  validates_uniqueness_of :fiscal_code, :email, :case_sensitive => false

  valid_email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,format: { with: valid_email_regex }

  valid_tel_regex = /\+\d\d\.\d+/i
  validates :telephone,format: { with: valid_tel_regex }, :allow_blank => true
  validates :fax, format: { with: valid_tel_regex }, :allow_blank => true

  valid_tel_regex = /^\d\d\d\d\d$/i
  validates :zip,format: { with: valid_tel_regex }

  attr_accessible :name, :surname, :company, :address1, :address2, :city, :zip, :country, :state,
                  :vat, :fiscal_code, :email, :telephone, :fax, :password, :password_confirmation, :remember_me

end
