# Present an artefact with a bare minimum of information.
#
# This speeds up the importer for the URL arbiter
# <https://github.com/alphagov/url-arbiter> by not loading up tag information.
class MinimalArtefactPresenter
  def initialize(artefact)
    @artefact = artefact
  end

  def as_json(options = {})
    {
      slug: @artefact.slug,
      name: @artefact.name,
      owning_app: @artefact.owning_app,
    }
  end
end
