#!/usr/bin/env ruby
#
# A proof-of-concept routing component. Matching slugs to apps and proxying
# requests that way.
#
# TODO: Better way to register apps' locations
# TODO: Is this going to be versatile enough?
# TODO: 404 handler
# TODO: Asynchronous database lookups
# TODO: Some logging
# TODO: Handle a load of static file paths

require 'em-proxy'
require 'uuid'

require File.expand_path('database', File.dirname(__FILE__))

host = "0.0.0.0"
port = 9889
puts "listening on #{host}:#{port}..."

def identify_slug(path_info)
  slug = path_info.split("/")[0]
  Identifier.first(slug: slug)
end

OUR_APPS = {
  'guides' => ['local.alphagov.co.uk', 3000],
  'publisher' => ['local.alphagov.co.uk', 3000]
}

Proxy.start(:host => host, :port => port) do |conn|
  conn.on_connect do |data,b|
    puts [:on_connect, data, b].inspect
  end

  conn.on_data do |data|
    if parts = data.match(/^(.+?) \/(.+?) HTTP\/\d\.\d/)
      session = UUID.generate
      identifier = identify_slug(parts[2])
      if identifier
        details = OUR_APPS[identifier.owning_app]
        conn.server session, :host => details[0], :port => details[1]
      else
        # some sort of 404 handler
      end
    end

    data
  end

  conn.on_response do |backend, resp|
    puts [:on_response, backend, resp].inspect
    resp
  end

  conn.on_finish do |backend, name|
    puts [:on_finish, name].inspect
  end
end
