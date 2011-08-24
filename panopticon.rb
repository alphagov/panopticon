require 'sinatra'
require 'json'
require File.expand_path('database', File.dirname(__FILE__))

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
    :slug => params['slug']['name'], 
    :owning_app => params['slug']['owning_app'], 
    :active => true,
    :kind => params['slug']['kind']
  )

  if new_resource.save
    status 201
  else
    puts new_resource.errors.inspect
    status 406
  end
end

get '/slugs/:id' do
  resource = Identifier.first(slug: params[:id])
  if resource
    content_type :json
    bits_we_care_about = resource.attributes.slice(:slug, :owning_app, :kind)
    
    if params['jsoncallback']
      puts "panopticon(#{bits_we_care_about.to_json})"
      return "panopticon(#{bits_we_care_about.to_json})"
    else
      bits_we_care_about.to_json
    end
  else
    status 404
  end
end
