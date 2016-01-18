require 'gds_api/content_store'

class ManualArtefactGuarantor
  attr_reader :manual_slug
  def initialize(manual_slug)
    @manual_slug = manual_slug
  end

  def guarantee
    if !content_item_exists?
      Guarantee.failure(manual_slug, reason: :does_not_exist)
    elsif !content_item_is_a_manual?
      Guarantee.failure(manual_slug, reason: :is_not_a_manual)
    elsif artefact_exists?
      handle_existing_artefact
    else
      handle_missing_artefact
    end
  end

  def content_item
    # Do this to allow memoizing the nils we get from a 404
    unless defined? @content_item
      @content_item = fetch_content_item
    end
    @content_item
  end

  def artefact
    unless defined? @artefact
      @artefact = fetch_artefact
    end
    @artefact
  end

  private

  def handle_existing_artefact
    if artefact_matches?
      Guarantee.success(manual_slug, content_id: content_item.content_id, reason: :artefact_already_exists)
    else
      Guarantee.failure(manual_slug, content_id: content_item.content_id, reason: :artefact_details_do_not_match)
    end
  end

  def artefact_exists?
    artefact.present?
  end

  def handle_missing_artefact
    create_artefact
    if artefact_persisted?
      Guarantee.success(manual_slug, content_id: content_item.content_id, reason: :artefact_created)
    else
      Guarantee.failure(manual_slug, content_id: content_item.content_id, reason: :artefact_creation_failed)
    end
  end

  def artefact_matches?
    (artefact.kind == content_item.format) && ("/#{artefact.slug}" == content_item.base_path)
  end

  def fetch_artefact
    Artefact.where(content_id: content_item.content_id).first
  end

  def create_artefact
    @artefact = Artefact.create(
      content_id: content_item.content_id,
      slug: content_item.base_path[1..-1],
      name: content_item.title,
      kind: 'manual',
      owning_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      language: content_item.locale,
      description: content_item.description,
      state: 'live',
      public_timestamp: content_item.public_updated_at,
      paths: [content_item.base_path],
    )
  end

  def artefact_persisted?
    artefact.persisted?
  end

  def content_item_is_a_manual?
    content_item.format == 'manual'
  end

  def content_item_exists?
    content_item.present?
  end

  def base_path
    "/guidance/#{manual_slug}"
  end

  def fetch_content_item
    content_store.content_item(base_path)
  end

  def content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.current.find('content-store'))
  end

  class Guarantee
    attr_reader :slug, :content_id, :reason
    def initialize(success, slug, content_id, reason)
      @success = !!success
      @slug = slug
      @content_id = content_id
      @reason = reason
    end

    def success?
      @success
    end

    def message
      "#{slug}#{content_id.present? ? "(#{content_id})" : ''} #{reason.to_s.humanize.downcase}"
    end

    def self.failure(slug, content_id: nil, reason:)
      new(false, slug, content_id, reason)
    end

    def self.success(slug, content_id:, reason:)
      new(true, slug, content_id, reason)
    end
  end
end
