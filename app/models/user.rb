class User
  include Mongoid::Document
  include Mongoid::Timestamps
  require 'bcrypt'
 
  field :name, type: String
  field :email, type: String
  field :crypted_password, type: String
  field :password_salt, type: String

  attr_accessor :password
  attr_accessible :email, :name, :password, :password_confirmation

  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates :email, format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates_uniqueness_of :email
 
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.crypted_password = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(email, password)
    user = find_by(email: email)
    if user && user.crypted_password == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
end
