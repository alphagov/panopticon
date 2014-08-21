require_relative '../test_helper'

class SearchIndexTest < ActiveSupport::TestCase

  test "builds a Rummageable::Index instance" do
    Rummageable::Index.expects(:new)
                        .with('http://search.dev', '/dapaas', has_key(:logger))
                        .returns('search client')

    client = SearchIndex.instance "dapaas"
    assert_equal 'search client', client
  end

end
