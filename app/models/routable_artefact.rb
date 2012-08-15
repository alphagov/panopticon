require 'router'

class RoutableArtefact

  def initialize(artefact)
    @artefact = artefact
  end

  def logger
    Rails.logger
  end

  def router
    @router ||= Router.new("http://router.cluster:8080/router")
  end

  def ensure_application_exists
    backend_url = URI.parse Plek.current.find(rendering_app)
    # Plek returns a full URL (https URL in production and preview).
    # We only want to pass the host to the router.
    router.update_application(rendering_app, backend_url.host)
  end

  def submit
    ensure_application_exists
    paths = (@artefact.paths || [])
    prefixes = (@artefact.prefixes || [])
    unless prefixes.include?(@artefact.slug)
      paths << @artefact.slug
    end
    paths.uniq.each do |path|
      logger.debug("Registering #{path} full #{rendering_app}")
      @router.create_route(path, "full", rendering_app)
    end
    prefixes.each do |prefix|
      logger.debug("Registering #{prefix} prefix #{rendering_app}")
      @router.create_route(prefix, "prefix", rendering_app)
    end
  end

  def delete
    ([@artefact.slug] + @artefact.paths + @artefact.prefixes).each do |path|
      router.delete_route(path)
    end
  end

  private
    def rendering_app
      @artefact.rendering_app || @artefact.owning_app
    end
end
