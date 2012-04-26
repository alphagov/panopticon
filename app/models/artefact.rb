class Artefact < ActiveRecord::Base
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

  has_many :related_items, :foreign_key => :source_artefact_id, :order => 'sort_key ASC', :dependent => :destroy
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
    return unless kind.present?
    self.kind = KIND_TRANSLATIONS[kind.to_s.downcase.strip]
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
