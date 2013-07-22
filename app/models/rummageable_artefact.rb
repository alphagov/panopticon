class RummageableArtefact

  FORMATS_NOT_TO_INDEX = %W(person)

  EXCEPTIONAL_SLUGS = %W(
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

    # API requests, if they know about the single registration API, will be
    # providing the indexable_content field to update Rummager. UI requests
    # and requests from apps that don't know about single registration, will
    # not include this field
    if should_amend
      logger.info "Posting amendments to Rummager: #{artefact_link}"
      Rummageable.amend artefact_link, artefact_hash
    else
      logger.info "Posting document to Rummager: #{artefact_link}"
      Rummageable.index [artefact_hash]
    end
  end

  def delete
    logger.info "Deleting item from Rummager: #{artefact_link}"
    Rummageable.delete(artefact_link)
    Rummageable.commit
  end

  def should_amend
    @artefact.indexable_content.nil?
  end

  def artefact_hash
    # This won't cope with nested values, but we don't have any of those yet
    # When we want to include additional links, this will become an issue
    rummageable_keys = Rummageable::VALID_KEYS.map {|full_key| full_key[0]}.uniq

    # When amending an artefact, requests with the "link" parameter will be
    # refused, because we can't amend the link within Rummager
    rummageable_keys.delete "link" if should_amend

    result = {}

    rummageable_keys.each_with_object(result) do |rummageable_key, hash|
      strip_nils = ["indexable_content", "description"].include? rummageable_key

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
    # travel advice fakes belonging to a section in frontend
    # this code continues the fakery so it'll display in search results
    # as belonging to the correct section
    if @artefact.kind == "travel-advice"
      result['section'] = 'foreign-travel-advice'
    end
    result
  end

  def artefact_section
    section_parts[0]
  end

  def artefact_subsection
    section_parts[1]
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
