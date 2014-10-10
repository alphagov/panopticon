GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = ENV['PANOPTICON_OAUTH_ID'] || "abcdefgh12345678pan"
  config.oauth_secret = ENV['PANOPTICON_OAUTH_SECRET'] || "secret"
  config.oauth_root_url = Plek.current.find("signon")
end

# In development, if we want to be able to test API requests to the tags
# endpoints, we need to override the permissions for the dummy user inserted by
# GDS::SSO in the mock_bearer_token strategy.
#
# The easiest way to do this is just to override the GDS::SSO test user with a
# new user we create here.
#
GDS::SSO.test_user = User.find_or_create_by(email: 'user@test.example').tap do |u|
  u.name = 'Testy McTest'
  u.permissions = ['signin', 'manage_tags']
  u.save!
end
