class RummageableArtefact

  FORMATS_NOT_TO_INDEX = %W(business_support completed_transaction) +
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["whitehall"] +
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["specialist-publisher"] +
    Artefact::FORMATS_BY_DEFAULT_OWNING_APP["finder-api"]

  EXCEPTIONAL_SLUGS = %W(
    gosuperfast
    growthaccelerator
    technology-strategy-board
    enterprise-finance-guarantee
    manufacturing-advisory-service-mas
    research-development-tax-credit-smes
    enterprise-investment-scheme
    seed-enterprise-investment-scheme
    designing-demand
    business-mentoring-support
    start-up-loans
    new-enterprise-allowance
    helping-your-business-grow-internationally
    unimoney
    horizon-2020
    civil-service-apprenticeships
  )

  def initialize(artefact)
    @artefact = artefact
  end

  def logger
    Rails.logger
  end

  def should_be_indexed?
    @artefact.live? && indexable_artefact?
  end

  def self.indexable_artefact?(kind, slug)
    (FORMATS_NOT_TO_INDEX.exclude?(kind) || EXCEPTIONAL_SLUGS.include?(slug))
  end

  def indexable_artefact?
    self.class.indexable_artefact?(@artefact.kind, @artefact.slug)
  end

  def submit
    return unless indexable_artefact?

    search_index = SearchIndex.instance

    # API requests, if they know about the single registration API, will be
    # providing the indexable_content field to update Rummager. UI requests
    # and requests from apps that don't know about single registration, will
    # not include this field
    if should_amend?
      logger.info "Posting amendments to Rummager: #{artefact_link}"
      search_index.amend artefact_link, artefact_hash
    else
      logger.info "Posting document to Rummager: #{artefact_link}"
      search_index.add artefact_hash
    end
  end

  def delete
    logger.info "Deleting item from Rummager: #{artefact_link}"

    search_index = SearchIndex.instance
    search_index.delete(artefact_link)
    search_index.commit
  end

  def should_amend?
    @artefact.indexable_content.nil?
  end

  def artefact_hash
    # This won't cope with nested values, but we don't have any of those yet
    # When we want to include additional links, this will become an issue
    rummageable_keys = %w{title description format
      indexable_content boost_phrases organisations additional_links
      specialist_sectors public_timestamp latest_change_note mainstream_browse_pages}

    # If a key is in this list, and the corresponding value in the artefact is
    # nil, then it will be omitted from the hash returned from this method
    strip_nil_keys = %w{
      indexable_content
      description
      public_timestamp
      latest_change_note
    }

    # When amending an artefact, requests with the "link" parameter will be
    # refused, because we can't amend the link within Rummager
    rummageable_keys << "link" unless should_amend?

    result = {}

    rummageable_keys.each_with_object(result) do |rummageable_key, hash|
      strip_nils = strip_nil_keys.include? rummageable_key

      # Use the relevant extraction method from this class if it exists
      if respond_to? "artefact_#{rummageable_key}"
        value = __send__ "artefact_#{rummageable_key}"
      elsif @artefact.respond_to? rummageable_key
        value = @artefact.__send__ rummageable_key
      else
        next
      end

      unless (strip_nils && value.nil?)
        hash[rummageable_key] = value
      end
    end

    result
  end

  def artefact_format
    @artefact.kind
  end

  def artefact_title
    @artefact.name
  end

  def artefact_link
    "/#{@artefact.slug}"
  end

  def artefact_organisations
    @artefact.organisation_ids
  end

  def artefact_specialist_sectors
    @artefact.specialist_sectors.map(&:tag_id)
  end

  def artefact_mainstream_browse_pages
    @artefact.sections.map(&:tag_id)
  end

  def artefact_public_timestamp
    if @artefact.public_timestamp
      @artefact.public_timestamp.iso8601
    end
  end

private
  def section_parts
    section_parts = []
    return section_parts if @artefact.sections.empty?

    if @artefact.primary_section.has_parent?
      section_parts.push(@artefact.primary_section.parent.tag_id)
    end
    section_parts.push(@artefact.primary_section.tag_id.split("/").last)
  end
end
