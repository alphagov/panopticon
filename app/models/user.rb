class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field "name",    type: String
  field "uid",     type: String
  field "version", type: Integer
  field "email",   type: String

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :uid, :version

  def self.find_for_gds_oauth(auth_hash)
    where(uid: auth_hash["uid"]).first || create_from_auth_hash(auth_hash)
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
