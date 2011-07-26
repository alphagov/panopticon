require 'sinatra'
require 'json'

require 'datamapper'
require 'dm-validations'
DataMapper::setup(:default, File.read(File.expand_path("../config/database.txt", __FILE__)))

class Resource
  include DataMapper::Resource
  
  property :id, Serial
  property :active, Boolean, :default => false, :required => true
  property :slug, String, :unique => true, :required => true, :length => 4..32
  property :owning_app, String, :required => true
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

post '/slugs' do
  new_resource = Resource.new(:slug => params[:slug][:name], :owning_app => params[:slug][:owning_app], :active => true)

  if new_resource.save
    status 201
  else
    status 406
  end
end