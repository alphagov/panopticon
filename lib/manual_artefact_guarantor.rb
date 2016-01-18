require 'gds_api/content_store'

class ManualArtefactGuarantor
  attr_reader :manual_slug
  def initialize(manual_slug)
    @manual_slug = manual_slug
  end

  def guarantee
    if !content_item_exists?
      Guarantee.failure(manual_slug, :does_not_exist)
    end
  end

  def content_item
    # Do this to allow memoizing the nils we get from a 404
    unless defined? @content_item
      @content_item = fetch_content_item
    end
    @content_item
  end

  private

  def content_item_exists?
    content_item.present?
  end

  def base_path
    "/#{manual_slug}"
  end

  def fetch_content_item
    content_store.content_item(base_path)
  end

  def content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.current.find('content-store'))
  end

  class Guarantee
    attr_reader :slug, :reason
    def initialize(success, slug, reason)
      @success = !!success
      @slug = slug
      @reason = reason
    end

    def success?
      @success
    end

    def message
      "#{slug} #{reason.to_s.humanize.downcase}"
    end

    def self.failure(slug, reason)
      new(false, slug, nil, reason)
    end
  end
end
