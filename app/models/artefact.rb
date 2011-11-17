class Artefact < ActiveRecord::Base
  MAXIMUM_RELATED_ITEMS = 8
  MAXIMUM_RELATED_CONTACTS = 3

  SECTIONS = [
    'Rights',
    'Justice',
    'Education and skills',
    'Work',
    'Family',
    'Money',
    'Taxes',
    'Benefits and schemes',
    'Driving',
    'Housing',
    'Communities',
    'Pensions',
    'Disabled people',
    'Travel',
    'Citizenship'
  ].freeze

  FORMATS = [
    "answer",
    "guide",
    "programme",
    "local_transaction",
    "transaction",
    "place"
  ].freeze

  has_many :related_items, :foreign_key => :source_artefact_id, :order => 'sort_key ASC', :dependent => :destroy 
  has_many :reverse_related_items, :foreign_key => :artefact_id, :class_name => 'RelatedItem', :order => 'sort_key ASC', :dependent => :destroy 
  has_many :related_artefacts, :through => :related_items, :source => :artefact  
  has_many :related_contacts, :order => 'sort_key ASC'
  has_many :contacts, :through => :related_contacts
  has_and_belongs_to_many :audiences

  before_validation :normalise, :on => :create

  after_update :broadcast_update

  validates :name, :presence => true
  validates :slug, :presence => true, :uniqueness => true
  validates :kind, :inclusion => { :in => FORMATS }

  accepts_nested_attributes_for :related_items,
    :allow_destroy  => true,
    :reject_if      => -> attributes { attributes[:artefact_id].blank? },
    :limit          => MAXIMUM_RELATED_ITEMS

  accepts_nested_attributes_for :related_contacts,
    :allow_destroy  => true,
    :reject_if      => -> attributes { attributes[:contact_id].blank? },
    :limit          => MAXIMUM_RELATED_CONTACTS

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

  def broadcast_update
    Messenger.instance.updated self
  end

  def to_param
    slug
  end

  def self.from_param(slug_or_id)
    # FIXME: A hack until the Publisher has panopticon ids for every article
    find_by_slug(slug_or_id) || find(slug_or_id)
  end
end
