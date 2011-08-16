require 'sinatra'
require 'json'

require 'datamapper'
require 'dm-validations'
DataMapper::setup(:default, File.read(File.expand_path("../config/database.txt", __FILE__)))

class Identifier
  include DataMapper::Resource
  
  property :id,         Serial
  property :active,     Boolean, :default => false, :required => true
  property :slug,       String,  :unique => true,   :required => true, :length => 4..32
  property :owning_app, String,  :required => true
  property :kind,       String,  :required => true
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

class Hash
  def slice(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    hash = {}
    allowed.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
end

post '/slugs' do
  new_resource = Identifier.new(
    :slug => params[:slug][:name], 
    :owning_app => params[:slug][:owning_app], 
    :active => true,
    :kind => params[:slug][:kind]
  )

  if new_resource.save
    status 201
  else
    status 406
  end
end

get '/slugs/:id' do
  resource = Identifier.first(slug: params[:id])
  if resource
    content_type :json
    bits_we_care_about = resource.attributes.slice(:slug, :owning_app, :kind)
    
    if params['jsonp']
      return "panopticon(#{bits_we_care_about.to_json})"
    else
      bits_we_care_about.to_json
    end
  else
    status 404
  end
end