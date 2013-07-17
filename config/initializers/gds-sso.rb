GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = ENV['PANOPTICON_OAUTH_ID'] || "abcdefgh12345678pan"
  config.oauth_secret = ENV['PANOPTICON_OAUTH_SECRET'] || "secret"
  config.oauth_root_url = Plek.current.find("signon")
  config.basic_auth_user = ENV['PANOPTICON_USER'] || "api"
  config.basic_auth_password = ENV['PANOPTICON_PASSWORD'] || "defined_on_rollout_not"
end