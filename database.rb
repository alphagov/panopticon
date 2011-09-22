require 'datamapper'
require 'dm-validations'
require 'cgi'
database_name = File.read(File.expand_path("../config/#{ENV['RACK_ENV']}.database.txt", __FILE__)).strip
DataMapper::setup(:default, database_name)

class Identifier
  include DataMapper::Resource
  
  property :id,         Serial
  property :active,     Boolean, :default => false, :required => true
  property :slug,       String,  :unique => true,   :required => true, :length => 4..63
  property :owning_app, String,  :required => true
  property :kind,       String,  :required => true
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!
