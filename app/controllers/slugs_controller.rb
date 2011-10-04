class SlugsController < ApplicationController
  def show
    artefact = Identity.find_by_slug params[:id]
    return head :not_found unless artefact.present?
    render :json => artefact.to_json
  end

  def create
    return head :not_acceptable if Artefact.find_by_slug params[:slug][:name]

    artefact = Identity.new
    # FIXME: [:slug][:name] is a legacy parameter, it shoud be
    #        [:artefact][:slug]
    artefact.slug = params[:slug][:name]
    # FIXME: This should be tested
    artefact.name = params[:slug][:name]
    # FIXME: This should be tested
    artefact.kind = params[:slug][:kind]
    # FIXME: This should be tested
    artefact.owning_app = params[:slug][:owning_app]
    # FIXME: This should be tested
    artefact.save!

    head :created
  end
end
