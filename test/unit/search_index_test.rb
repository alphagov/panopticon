require_relative '../test_helper'

class SearchIndexTest < ActiveSupport::TestCase

  test "builds a Rummageable::Index instance" do
    Rummageable::Index.expects(:new)
                        .with('http://search.dev.gov.uk', '/mainstream', has_key(:logger))
                        .returns('search client')

    client = SearchIndex.instance
    assert_equal 'search client', client
  end

end
