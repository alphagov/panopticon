require 'router'

class RoutableArtefact

  def initialize(artefact)
    @artefact = artefact
  end

  def logger
    Rails.logger
  end

  def router
    @router ||= Router.new
  end

  def ensure_application_exists
    backend_url = Plek.current.find(@artefact.owning_app)
    router.update_application(@artefact.owning_app, backend_url)
  end

  def submit
    ensure_application_exists
    paths = (@artefact.paths || [])
    prefixes = (@artefact.prefixes || [])
    unless prefixes.include?(@artefact.slug)
      paths << @artefact.slug
    end
    paths.uniq.each do |path|
      @router.create_route(path, "full", @artefact.owning_app)
    end
    prefixes.each do |prefix|
      @router.create_route(prefix, "prefix", @artefact.owning_app)
    end
  end
end