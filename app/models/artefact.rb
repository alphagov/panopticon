require 'marples/model_action_broadcast'

class Artefact
  include Mongoid::Document
  include Mongoid::Timestamps

  include Marples::ModelActionBroadcast
  self.marples_client_name = 'panopticon'
  self.marples_logger = Rails.logger


  # NOTE: these fields are deprecated, and soon to be replaced with a
  # tag-based implementation
  field "department",           type: String
  field "tags",                 type: String
  field "business_proposition", type: Boolean, default: false

  field "name",                 type: String
  field "slug",                 type: String
  field "kind",                 type: String
  field "owning_app",           type: String
  field "active",               type: Boolean, default: false
  field "need_id",              type: String
  field "fact_checkers",        type: String
  field "relatedness_done",     type: Boolean, default: false
  field "publication_id",       type: String
  field "tag_ids",              type: Array, default: []
  field "primary_section",      type: String

  MAXIMUM_RELATED_ITEMS = 8

  FORMATS = [
    "answer",
    "guide",
    "programme",
    "local_transaction",
    "transaction",
    "place",
    "smart-answer",
    "custom-application"
  ].freeze

  KIND_TRANSLATIONS = {
    'standard transaction link'        => 'transaction',
    'local authority transaction link' => 'local_transaction',
    'benefit / scheme'                 => 'programme',
    'find my nearest'                  => 'place',
  }.tap { |h| h.default_proc = -> _, k { k } }.freeze

  has_and_belongs_to_many :related_artefacts, :class_name => "Artefact"
  belongs_to :contact

  before_validation :normalise, :on => :create

  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true, :slug => true
  validates :kind, :inclusion => { :in => FORMATS }
  validates_presence_of :owning_app

  # TODO: Remove this 'unless' hack after importing. It's only here because
  # some old entries in Panopticon lack a need_id.
  validates_presence_of :need_id, :unless => lambda { defined? IMPORTING_LEGACY_DATA }

  def self.in_alphabetical_order
    order_by([[:name, :asc]])
  end

  def self.find_by_slug(s)
    where(slug: s).first
  end

  # The old-style section string identifier, of the form 'Crime:Prisons'
  def section
    return '' unless self.primary_section
    primary_section_tag = TagRepository.load self.primary_section
    if primary_section_tag.parent
      [primary_section_tag.parent.title, primary_section_tag.title].join ':'
    else
      primary_section_tag.title
    end
  end

  # primary section is the home section for the artefact
  # this is used to display the bread crumb
  def primary_section=(section_id)
    t = TagRepository.load(section_id)
    raise "Missing tag '#{t}" if t.nil?
    raise "Tag #{t} is not a section" if t[:tag_type] != 'section'

    self['primary_section'] = section_id
    if not self.tag_ids.include?(section_id)
      self.tag_ids.insert(0, section_id)
    end
  end

  # All the section tags assigned to this artefact
  def sections
    self.tag_ids.select { |t| TagRepository.load(t).tag_type == 'section' }
  end

  # Set the section tags for this artefact
  def sections=(section_ids)
    # Check each new section ID exists
    new_tags = section_ids.map { |i| TagRepository.load i }
    new_tags.each do |new_tag|
      raise "Missing tag '#{new_tag}" if new_tag.nil?
      raise "Tag #{new_tag} is not a section" if new_tag[:tag_type] != 'section'
    end

    self.tag_ids = (self.tag_ids or []).reject do |tag_id|
      tag = TagRepository.load(tag_id)
      tag.tag_type == 'section'
    end

    self.tag_ids = (self.tag_ids + section_ids).uniq

    # we are implying an order to section tags here
    # the first section tag is the same as the primary_section
    if self.primary_section.present? and self.tag_ids[0] != self.primary_section
      self.tag_ids.insert(0, self.primary_section)
    end
    return nil
  end

  def normalise
    return unless kind.present?
    self.kind = KIND_TRANSLATIONS[kind.to_s.downcase.strip]
  end

  def admin_url(options = {})
    [ "#{Plek.current.find(owning_app)}/admin/publications/#{id}",
      options.to_query
    ].reject(&:blank?).join("?")
  end

  # TODO: Replace this nonsense with a proper API layer.
  def as_json(options={})
    super(options.merge(
      include: {contact: {}}
    )).tap { |hash|
      if hash['tag_ids']
        hash['tag_ids'] = hash['tag_ids'].map { |tag_id| TagRepository.load(tag_id).as_json }
      else
        hash.delete 'tag_ids'
      end

      unless options[:ignore_related_artefacts]
        hash["related_items"] = related_artefacts.map { |a| {"artefact" => a.as_json(ignore_related_artefacts: true)} }
      end
      hash.delete("related_artefacts")
      hash.delete("related_artefact_ids")
      hash["id"] = hash.delete("_id")
      hash["contact"]["id"] = hash["contact"].delete("_id") if hash["contact"]

      # Add a section identifier if needed
      hash["section"] ||= section
    }
  end

  def self.from_param(slug_or_id)
    # FIXME: A hack until the Publisher has panopticon ids for every article
    find_by_slug(slug_or_id) || find(slug_or_id)
  rescue BSON::InvalidObjectId
    raise Mongoid::Errors::DocumentNotFound.new(self, slug_or_id)
  end
end
