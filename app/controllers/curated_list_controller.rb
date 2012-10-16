require 'curated_list/file_verifier'
require 'govspeak'

class CuratedListController < ApplicationController
  respond_to :html
  class HtmlValidationError < StandardError; end
  class EmptyArtefactArray < StandardError; end

  def create
    prohibit_non_csv_uploads
    @data_file = params[:data_file]
    process_data_file
    flash[:success] = "Hooray! That worked and you can now upload new data."
    redirect_to curated_list_path
  rescue CSV::MalformedCSVError => e
    flash[:error] = "That looks like it isn't a CSV file."
    redirect_to curated_list_path
  rescue HtmlValidationError => e
    flash[:error] = "Failed at being a valid document."
    redirect_to curated_list_path
  rescue EmptyArtefactArray => e
    flash[:error] = "There's an empty row of artefact slugs against a sub category."
    redirect_to curated_list_path
  end

  protected
  def prohibit_non_csv_uploads
    if params[:data_file]
      file = get_file_from_param(params[:data_file])
      fv = CuratedListImport::FileVerifier.new(file)
      unless fv.type == 'text'
        Rails.logger.info "Rejecting file with content type: #{fv.mime_type}"
        raise CSV::MalformedCSVError
      end
    end
  end

  def process_data_file
    if @data_file
      data = @data_file.read.force_encoding('UTF-8')
      if Govspeak::Document.new(data).valid?
        csv_obj = CSV.parse(data, headers: true)
        # eg: [sub_category_slug, artefact, artefact, artefact]
        csv_obj.each do |row|
          row = row.map { |k,v| v && v.strip }
          # lookup if curated list exists
          curated_list = CuratedList.any_in(tag_ids: [row[0]]).first
          if curated_list.nil?
            curated_list = CuratedList.new()
            # remove the slash from our tag_id
            tag_id = row[0].slice(1..-1)

            # HACKY: slug can't be empty, so for now we'll use the tag_id. Ick.
            curated_list.slug = tag_id.parameterize
            curated_list.sections = [tag_id]
          end
          artefact_slugs = row.select {|x| !x.nil?}
          artefact_slugs.shift
          if artefact_slugs.length > 0
            curated_list.artefact_ids = artefacts_in_order(artefact_slugs).map(&:id)
            curated_list.save!
          else
            raise EmptyArtefactArray
          end
        end
      else
        raise HtmlValidationError
      end
    end
  end

  def artefacts_in_order(slugs)
    artefacts_by_slug = slugs.each_with_object({}) { |v,h| h[v] = nil }
    artefacts = Artefact.any_in(slug: slugs)
    artefacts.each do |artefact|
      artefacts_by_slug[artefact.slug] = artefact
    end
    artefacts_by_slug.values.compact
  end

  def get_file_from_param(param)
    if param.respond_to?(:tempfile)
      param.tempfile
    else
      param
    end
  end

end
