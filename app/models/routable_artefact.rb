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

  # Ensure the backend app exists in the router so that the routes below
  # can reference it.
  def ensure_backend_exists
    backend_url = Plek.current.find(rendering_app, :force_http => true) + "/"
    router_api.add_backend(rendering_app, backend_url)
  end

  def submit(options = {})
    if artefact.live?
      register
    elsif artefact.owning_app == "whitehall"
      return
    elsif artefact.archived? && artefact.redirect_url.present?
      redirect(artefact.redirect_url)
    elsif artefact.archived?
      delete
    else
      return
    end

    if options[:skip_commit] || prefixes.empty? && paths.empty?
      return
    end

    commit
  end

  def register
    ensure_backend_exists
    prefixes.each do |path|
      logger.debug("Registering route #{path} (prefix) => #{rendering_app}")
      router_api.add_route(path, "prefix", rendering_app)
    end
    paths.each do |path|
      logger.debug("Registering route #{path} (exact) => #{rendering_app}")
      router_api.add_route(path, "exact", rendering_app)
    end
  end

  def delete
    prefixes.each do |path|
      begin
        logger.debug "Removing route #{path}"
        router_api.add_gone_route(path, "prefix")
      rescue GdsApi::HTTPNotFound
      end
    end
    paths.each do |path|
      begin
        logger.debug "Removing route #{path}"
        router_api.add_gone_route(path, "exact")
      rescue GdsApi::HTTPNotFound
      end
    end
  end

  def redirect(destination)
    prefixes.each do |path|
      begin
        logger.debug "Removing route #{path}"
        router_api.add_redirect_route(path, "prefix", destination)
      rescue GdsApi::HTTPNotFound
      end
    end
    paths.each do |path|
      begin
        logger.debug "Removing route #{path}"
        router_api.add_redirect_route(path, "exact", destination)
      rescue GdsApi::HTTPNotFound
      end
    end
  end

  def commit
    router_api.commit_routes
  end

  private

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
