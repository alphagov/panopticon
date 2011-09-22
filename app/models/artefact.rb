class Artefact < ActiveRecord::Base
  MAXIMUM_RELATED_ITEMS = 6

  has_many :related_items, :foreign_key => :source_artefact_id, :order => 'sort_key desc'
  has_many :related_artefacts, :through => :related_items, :source => :artefect
  has_and_belongs_to_many :audiences

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

  def normalise
    normalise_kind
  end

  def normalise_kind
    return unless kind.present?
    self.kind = kind.to_s.downcase.strip
    self.kind = 'transaction' if [ 'local authority transaction link', 'standard transaction link', 'benefit / scheme'].include? kind
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
end
