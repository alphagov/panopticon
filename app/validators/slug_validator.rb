class SlugValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    unless ActiveSupport::Inflector.parameterize(value.to_s) == value.to_s
      record.errors[attribute] << 'must be usable in a URL'
    end
  end
end
