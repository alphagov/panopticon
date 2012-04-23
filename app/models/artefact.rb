class Artefact < ActiveRecord::Base
  MAXIMUM_RELATED_ITEMS = 8

  def self.sections
    @@sections ||= load_sections
  end

  def self.load_sections
    section = nil
    File.open(Rails.root.join('app', 'models', 'sections.txt'), 'r').map do |line|
      if line =~ /^  /
        raise "Bad section.txt, must start with a section (no spaces at start of first line)" if section.nil?
        "#{section}:#{line.strip}"
      else
        section = line.strip
      end
    end
  end

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

  has_many :related_items, :foreign_key => :source_artefact_id, :order => 'sort_key ASC', :dependent => :destroy
  has_many :reverse_related_items, :foreign_key => :artefact_id, :class_name => 'RelatedItem', :order => 'sort_key ASC', :dependent => :destroy
  has_many :related_artefacts, :through => :related_items, :source => :artefact
  belongs_to :contact

  before_validation :normalise, :on => :create

  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true, :slug => true
  validates :kind, :inclusion => { :in => FORMATS }
  validates_presence_of :owning_app
  validates_presence_of :need_id

  accepts_nested_attributes_for :related_items,
    :allow_destroy  => true,
    :reject_if      => -> attributes { attributes[:artefact_id].blank? },
    :limit          => MAXIMUM_RELATED_ITEMS

  scope :in_alphabetical_order, order('name ASC')

  def normalise
    normalise_kind
  end

  def normalise_kind
    return unless kind.present?
    self.kind = kind.to_s.downcase.strip
    self.kind = 'transaction' if kind == 'standard transaction link'
    self.kind = 'local_transaction' if kind == 'local authority transaction link'
    self.kind = 'programme' if kind == 'benefit / scheme'
    self.kind = 'place' if kind == 'find my nearest'
  end

  def admin_url
    app = Plek.current.find owning_app
    app += '/admin/publications/' + id.to_s
  end

  def to_json(options)
    super(options.merge(
      :include => {
        :related_items  => { :include => :artefact }, # TODO use :related_artefacts => {}
        :contact        => {}
      }
    ))
  end

  def self.from_param(slug_or_id)
    # FIXME: A hack until the Publisher has panopticon ids for every article
    find_by_slug(slug_or_id) || find(slug_or_id)
  end
end
