require_relative '../test_helper'

class SearchIndexTest < ActiveSupport::TestCase

  test "builds a Rummageable::Index instance" do
    SearchIndex.remove_class_variable :@@instance if SearchIndex.class_variable_defined?(:@@instance)
    Rummageable::Index.expects(:new)
                        .with('http://search.dev.gov.uk', '/mainstream', has_key(:logger))
                        .returns('search client')

    client = SearchIndex.instance
    assert_equal 'search client', client
    SearchIndex.remove_class_variable :@@instance
  end

end
