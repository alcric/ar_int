class Record
  include Mongoid::Document
  require 'net/ping'
  require 'net/dns/resolver'

  field :nome, :type => String
  field :tipo, :type => String
  field :risposta, :type => String
  field :cluster, :type => Hash
  field :ttl, :type => Integer

  attr_accessor :priority, :weight, :port, :dest, :terzo_livello
  before_validation :create_name, :create_risposta

  validates_presence_of :nome, :tipo, :risposta
  validates_uniqueness_of :nome, :if => :is_type_a?

#  index(
#      [
#        [ :nome, Mongo::ASCENDING ],
#        [ :type, Mongo::ASCENDING ]
#      ]
#    )

  belongs_to :domain
  
  def decode_name
    if self.nome == self.domain.name
      self.terzo_livello=''
    else
      self.terzo_livello=self.nome.sub ".#{self.domain.name}", ''
    end
  end

  def decode_dest
    if self.tipo == 'MX'
      self.priority,self.dest= self.risposta.split("\t")
    elsif self.tipo == 'SRV'
      self.priority,self.weight,self.port,self.dest = self.risposta.split(" ")
    else
      self.dest=self.risposta
    end
  end

  private

  def is_type_a?
    return self.tipo.to_s == 'A'
  end

  def is_type_mx?
    return self.tipo.to_s == 'MX'
  end

  def is_type_ns?
    return self.tipo.to_s == 'NS'
  end

  def is_type_srv?
    return self.tipo.to_s == 'SRV'
  end

  def is_type_cname?
    return self.tipo.to_s == 'CNAME'
  end

  def is_ip?(data)
    return /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/.match(data)
  end

  def is_fqdn?(data)
    return /[a-z\d\-.]+\.[a-z]+\z/.match(data)
  end

  def create_name
    unless @terzo_livello.to_s == ''
      self.nome = @terzo_livello.to_s + '.' + self.domain.name
    else
      self.nome = self.domain.name
    end
  end

  def check_mx_data(record)
    ret=true
    if record.priority.blank?
      record.errors[:priority]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless record.priority == record.priority.to_i.to_s
        record.errors[:priority]= I18n.t('errors.messages.invalid')
        ret=false
      else
         if record.priority.to_i < 0
          record.errors[:priority]= I18n.t('errors.messages.invalid')
          ret=false
        end
      end
    end

    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless is_fqdn?(record.dest)
        record.errors[:dest]= I18n.t('errors.messages.invalid')
        ret=false
      else
        is_an_a_record=false
        packet = Net::DNS::Resolver.start(record.dest)
        packet.each_address do |ip|
          is_an_a_record=true
          p1 = Net::Ping::TCP.new((ip.to_s), 'smtp')
          unless p1.ping?
            record.errors[:dest]= I18n.t('always_resolve.error.bind_port')
            ret=false
          end
        end
        unless is_an_a_record
          record.errors[:dest]= I18n.t('always_resolve.error.not_correct_destination_type')
          ret=false
        end
      end
    end
    return ret
  end

  def check_srv_data(record)
    ret=true
    if record.priority.blank?
      record.errors[:priority]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless record.priority == record.priority.to_i.to_s
        record.errors[:priority]= I18n.t('errors.messages.invalid')
        ret=false
      else
         if record.priority.to_i < 0
          record.errors[:priority]= I18n.t('errors.messages.invalid')
          ret=false
        end
      end
    end

    if record.weight.blank?
      record.errors[:weight]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless record.weight == record.weight.to_i.to_s
        record.errors[:weight]= I18n.t('errors.messages.invalid')
        ret=false
      else
         if record.weight.to_i < 0
          record.errors[:weight]= I18n.t('errors.messages.invalid')
          ret=false
        end
      end
    end

    if record.port.blank?
      record.errors[:port]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless record.port == record.port.to_i.to_s
        record.errors[:port]= I18n.t('errors.messages.invalid')
        ret=false
      else
         if record.port.to_i < 0 or record.port.to_i > 65535
          record.errors[:port]= I18n.t('errors.messages.invalid')
          ret=false
        end
      end
    end

    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless is_fqdn?(record.dest)
        record.errors[:dest]= I18n.t('errors.messages.invalid')
        ret=false
      else
        is_an_a_record=false
        packet = Net::DNS::Resolver.start(record.dest)
        packet.each_address do |ip|
          is_an_a_record=true
        end
        unless is_an_a_record
          record.errors[:dest]= I18n.t('always_resolve.error.not_correct_destination_type')
          ret=false
        end
      end
    end
    return ret
  end

  def check_ns_data(record)
    ret=true
    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless is_fqdn?(record.dest)
        record.errors[:dest]= I18n.t('errors.messages.invalid')
        ret=false
      else
        is_an_a_record=false
        packet = Net::DNS::Resolver.start(record.dest)
        packet.each_address do |ip|
          is_an_a_record=true
          res = Net::DNS::Resolver.new(:nameserver => ip,
                                       :recursive => false,
                                       :retry => 10
                                       ).query(record.nome, Net::DNS::NS)
          ns_authoritative = false
          res.answer.each do |rr|
            ns_authoritative = true
          end
          unless ns_authoritative
            record.errors[:dest]= I18n.t('always_resolve.error.dns_not_authoritative')
            ret=false
          end
        end
        unless is_an_a_record
          record.errors[:dest]= I18n.t('always_resolve.error.dns_not_found')
          ret=false
        end
      end
    end
    return ret
  end

  def check_cname_data(record)
    ret=true
    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless is_fqdn?(record.dest)
        record.errors[:dest]= I18n.t('errors.messages.invalid')
        ret=false
      end
    end
    return ret
  end

  def check_a_data(record)
    ret=true
    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    else
      unless is_ip?(record.dest)
        record.errors[:dest]= I18n.t('errors.messages.invalid')
        ret=false
      end
    end
    return ret
  end

  def check_txt_data(record)
    ret=true
    if record.dest.blank?
      record.errors[:dest]= I18n.t('errors.messages.blank')
      ret=false
    end
    return ret
  end

  def create_risposta
    unless @dest.to_s.nil?
      if (self.tipo == 'MX')
        if check_mx_data(self)
          self.risposta = self.priority + "\t" + self.dest
        end
      elsif (self.tipo == 'SRV')
        if check_srv_data(self)
          self.risposta = self.priority + " " + self.weight + " " + self.port + " "  + self.dest
        end
      elsif (self.tipo == "NS")
        if check_ns_data(self)
          self.risposta = self.dest
        end
      elsif (self.tipo == "CNAME")
        if check_cname_data(self)
          self.risposta = self.dest
        end
      elsif (self.tipo == "TXT")
        if check_txt_data(self)
          self.risposta = self.dest
        end
      elsif (self.tipo == "A")
        if check_a_data(self)
          self.risposta = self.dest
        end
      end
    end
  end

end
