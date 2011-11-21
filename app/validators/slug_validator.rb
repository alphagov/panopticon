class SlugValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'must be usable in a URL' unless value.parameterize.to_s == value.to_s
  end
end