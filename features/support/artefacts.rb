def artefact_called(name)
  record_called Artefact, name
end

def relate_records_to_artefact_called(artefact_name, association_name, related_names)
  reflection          = Artefact.reflect_on_association association_name
  related_class       = reflection.klass
  attribute           = reflection.source_reflection.name
  through_association = artefact_called(artefact_name).send reflection.through_reflection.name
  max_sort_key        = through_association.maximum(:sort_key) || -1

  records_called(related_class, related_names).each.with_index(max_sort_key + 1) do |record, sort_key|
    through_association.create! attribute => record, :sort_key => sort_key
  end
end
