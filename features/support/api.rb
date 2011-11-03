def assert_api_relates_records_to_artefact_called(name, related_class, related_names, assert_not)
  visit artefact_path(artefact_called(name), :format => :js)
  record_ids = yield JSON.parse(source).with_indifferent_access

  records_called(related_class, related_names).each do |record|
    if assert_not
      assert_not_include record_ids, record.id
    else
      assert_include record_ids, record.id
    end
  end
end
