ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default
require File.expand_path('database', File.dirname(__FILE__))

class Hash
  def slice(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    hash = {}
    allowed.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
end

class SlugGenerator
  attr_accessor :text
  private :text=, :text

  def initialize text
    self.text = text
  end

  def execute
    result = text.dup
    result.strip!
    result.gsub! /[^a-zA-Z0-9]+/, '-'
    result.gsub! /\s+/, '-'
    result.gsub! /^-+|-+$/, ''
    result.downcase!
    result
  end
end

class Artefact
  attr_accessor :name, :slug, :kind, :tags
  private :name=, :name, :slug=, :slug, :kind=, :kind, :tags=, :tags

  def initialize details
    self.name = details['name']
    self.slug = SlugGenerator.new(details['name']).execute
    self.kind = details['kind']
    self.tags = details['tags']
  end

  # FIXME: This is a nasty hack that makes too many assumptions
  def admin_url
    "http://#{Plek.current.publisher}/admin/#{kind}s/new?#{query_string}"
  end

  def query_string
    [
      query_param(:name),
      query_param(:slug),
      query_param(:tags)
    ].join '&'
  end
  private :query_string

  def query_param attribute
    "#{CGI.escape(kind.to_s)}[#{CGI.escape(attribute.to_s)}]=#{CGI.escape(send(attribute).to_s)}"
  end
  private :query_param
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
    status 406
  end
end

get '/slugs/:id' do
  resource = Identifier.first(slug: params[:id])
  if resource
    content_type :json
    bits_we_care_about = resource.attributes.slice(:slug, :owning_app, :kind)

    if params['jsoncallback']
      return "panopticon(#{bits_we_care_about.to_json})"
    else
      bits_we_care_about.to_json
    end
  else
    status 404
  end
end

post '/artefacts' do
  artefact = Artefact.new params['artefact']
  redirect artefact.admin_url
end
