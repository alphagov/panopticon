class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field "name",    type: String
  field "uid",     type: String
  field "version", type: Integer
  field "email",   type: String

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :uid, :version

  # GDS::SSO specifically looks for find_by_uid within warden
  # when loading authentication user from session
  def self.find_by_uid(uid)
    where(uid: uid).first
  end

  # GDS::SSO override for first time authentication of the app
  def self.find_for_gds_oauth(auth_hash)
    find_by_uid(auth_hash["uid"]) || create_from_auth_hash(auth_hash)
  end

  def self.create_from_auth_hash(auth_hash)
    user_params = auth_hash['extra']['user_hash'].select { |k,v|
      %w[ uid email name version ].include?(k)
    }
    User.create!(user_params)
  end

  def to_s
    email
  end
end
