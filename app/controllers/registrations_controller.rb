class RegistrationsController < ApplicationController
  respond_to :json

  # We're presuming that all registrations are for published items
  # that should be stored in panopticon and registered in search.
  # Items are matched on 'slug' and new details will replace any
  # previous item with that slug
  def create
    structure = normalise_keys(JSON.parse(params[:resource]))
    
    artefact = find_or_build_artefact(structure)

    if artefact.save!
      Rummageable.index(rummageable_params(structure))
    end

    respond_with artefact
  end

  protected
  def find_or_build_artefact(structure)
    Artefact.find_or_initialize_by_slug(structure[:slug]).tap do |artefact|
      artefact.attributes = structure.slice(*Artefact.attribute_names)
    end
  end

  # A translation layer because we have inconsistent language.
  # TODO: Make language consistent so this isn't needed any more
  def normalise_keys(structure)
    structure["name"] ||= structure["title"]
    structure["kind"] ||= structure["format"]
    structure["kind"] = 'smart-answer' if structure["kind"] == 'smart_answer'

    structure
  end

  def rummageable_params(structure)
    structure.slice(Rummageable::VALID_KEYS)
  end
end
