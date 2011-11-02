class Artefact < ActiveRecord::Base
  MAXIMUM_RELATED_ITEMS = 6

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

  DEPARTMENTS = [
    "Attorney general's office",
    "Cabinet office",
    "Department for business, innovation and skills",
    "Department for communities and local government",
    "Department for culture, media and sport",
    "Department for education",
    "Department for environment, food and rural affairs",
    "Department for international development",
    "Department for transport",
    "Department for work and pensions",
    "Department of energy and climate change",
    "Department of health",
    "Foreign and commonwealth office",
    "HM treasury",
    "HM revenue & customs",
    "Home office",
    "Ministry of defence",
    "Ministry of justice",
    "Northern Ireland office",
    "Office of the advocate general for Scotland",
    "Office of the leader of the house of commons",
    "Privy council office",
    "Scotland office",
    "Wales office",
  ].freeze

  FORMATS = [
    "answer",
    "guide",
    "programme",
    "local_transaction",
    "transaction",
    "place"
  ].freeze

  has_many :related_items, :foreign_key => :source_artefact_id, :order => 'sort_key desc'
  has_many :related_artefacts, :through => :related_items, :source => :artefact
  has_and_belongs_to_many :audiences

  before_validation :normalise, :on => :create
  
  after_update :broadcast_update

  validates_presence_of :name
  validates_uniqueness_of :slug
  validates_presence_of :slug
  validates_inclusion_of :kind, :in => FORMATS

  def self.related_items
    all :order => 'name asc'
  end

  def item_relation_number number
    related_items.find_by_sort_key number
  end
  private :item_relation_number

  def related_artefact_number number
    relation = item_relation_number number
    return unless relation.present?
    relation.artefact
  end
  private :related_artefact_number

  def delete_item_relation number
    item = item_relation_number number
    return unless item.present?
    item.destroy
  end
  private :delete_item_relation

  def set_related_item number, artefact
    delete_item_relation number
    related_items.create! :sort_key => number, :artefact => artefact
  end
  private :set_related_item

  MAXIMUM_RELATED_ITEMS.times do |related_item_offset|
    related_item = "related_item_#{related_item_offset}"
    define_method related_item do
      artefact = related_artefact_number related_item_offset
      return unless artefact.present?
      artefact.id
    end

    define_method "#{related_item}=" do |id|
      delete_item_relation related_item_offset
      return unless id.present?
      artefact = Artefact.find_by_id id
      return unless artefact.present?
      set_related_item related_item_offset, artefact
    end
  end

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

  def as_json *args
    options = args.extract_options!
    unless options[:include]
      options[:include] = {}
      options[:include].merge! :audiences => {}
      options[:include].merge! :related_items => { :include => [ :artefact ] }
    end
    args << options
    super *args
  end
  
  def broadcast_update
    Messenger.instance.updated self
  end
end
