require 'gds_api/base'
require 'gds_api/need_api'

Panopticon.need_api = GdsApi::NeedApi.new(Plek.current.find("need-api"),
  timeout: 1,
  bearer_token: ENV["panopticon_need_api_bearer_token"] || "change me when you deploy"
)
