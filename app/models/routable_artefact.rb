require 'plek'
require 'gds_api/router'

class RoutableArtefact

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
    ensure_backend_exists
    prefixes.each do |path|
      logger.debug("Registering route #{path} (prefix) => #{rendering_app}")
      router_api.add_route(path, "prefix", rendering_app, :skip_commit => true)
    end
    paths.each do |path|
      logger.debug("Registering route #{path} (exact) => #{rendering_app}")
      router_api.add_route(path, "exact", rendering_app, :skip_commit => true)
    end
    commit unless options[:skip_commit]
  end

  def delete(options = {})
    prefixes.each do |path|
      begin
        logger.debug "Removing route #{path} (prefix)"
        router_api.delete_route(path, "prefix", :skip_commit => true)
      rescue GdsApi::HTTPNotFound
      end
    end
    paths.each do |path|
      begin
        logger.debug "Removing route #{path} (exact)"
        router_api.delete_route(path, "exact", :skip_commit => true)
      rescue GdsApi::HTTPNotFound
      end
    end
    commit unless options[:skip_commit]
  end

  def commit
    router_api.commit_routes
  end

  private

  def rendering_app
    @rendering_app ||= [@artefact.rendering_app, @artefact.owning_app].reject(&:blank?).first
  end

  def paths
    @artefact.paths || []
  end

  def prefixes
    @artefact.prefixes || []
  end
end
