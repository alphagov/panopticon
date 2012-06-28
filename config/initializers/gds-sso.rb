GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = 'abcdefgh12345678pan'
  config.oauth_secret = 'secret'
  config.default_scope = "Panopticon"
  config.oauth_root_url = Plek.current.find("authentication")
  config.basic_auth_user = 'api'
  config.basic_auth_password = 'defined_on_rollout_not'
end
