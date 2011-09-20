class ArtefactsController < ApplicationController
  def create
    artefact = Artefact.new
    artefact.name = params[:artefact][:name]
    artefact.slug = SlugGenerator.new(params[:artefact][:name]).execute
    artefact.kind = params[:artefact][:kind]
    artefact.owning_app = params[:artefact][:owning_app]
    artefact.tags = params[:artefact][:tags]

    redirect_to artefact.admin_url, :status => :see_other
  end
end
