require 'gds_api/test_helpers/whitehall_admin_api'
require 'gds_api/test_helpers/publisher'

include GdsApi::TestHelpers::WhitehallAdminApi
include GdsApi::TestHelpers::Publisher

Before('@stub-topic-reindex-endpoints') do
  stub_all_whitehall_admin_api_requests
  stub_all_publisher_api_requests
end
