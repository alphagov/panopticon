require 'curated_list/file_verifier'
require 'govspeak'

class CuratedListController < ApplicationController
  respond_to :html

  def create
    prohibit_non_csv_uploads
    @data_file = params[:data_file]
    process_data_file
    render action: 'import', :locals => {:status => "SUCCESS!"}
  rescue CSV::MalformedCSVError => e
    render action: 'import', :locals => {:error => "Could not process CSV file. Please check the format."}
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
          # Place.create_from_hash(self, row)
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
            curated_list.artefact_ids = Artefact.any_in(slug: artefact_slugs).collect(&:_id)
            curated_list.save!
          else
            # TODO: rescue from this error and display message
            raise "Stop! No artefact_slugs found in data file"
          end
        end
      else
        raise HtmlValidationError
      end
    end
  end

  def get_file_from_param(param)
    if param.respond_to?(:tempfile)
      param.tempfile
    else
      param
    end
  end

end
