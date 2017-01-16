require 'plek'
require 'gds_api/router'

class RoutableArtefact

  attr_reader :artefact

  def initialize(artefact)
    @artefact = artefact
  end

  def logger
    Rails.logger
  end

  def router_api
    @router_api ||= GdsApi::Router.new(Plek.current.find('router-api'))
  end

  def submit(options = {})
    unless allowed_to_register_routes_here_even_though_it_should_use_the_publishing_api?
      return
    end

    if artefact.live?
      register
    else
      return
    end

    if options[:skip_commit] || prefixes.empty? && paths.empty?
      return
    end

    commit
  end

  def register
    prefixes.each do |path|
      logger.debug("Registering route #{path} (prefix) => #{rendering_app}")
      router_api.add_route(path, "prefix", rendering_app)
    end
    paths.each do |path|
      logger.debug("Registering route #{path} (exact) => #{rendering_app}")
      router_api.add_route(path, "exact", rendering_app)
    end
  end

  def commit
    router_api.commit_routes
  end

  private


  def allowed_to_register_routes_here_even_though_it_should_use_the_publishing_api?
    artefact.owning_app.in?([
      OwningApp::PUBLISHER,
    ])
  end

  def rendering_app
    @rendering_app ||= [artefact.rendering_app, artefact.owning_app].reject(&:blank?).first
  end

  def paths
    artefact.paths || []
  end

  def prefixes
    artefact.prefixes || []
  end
end
