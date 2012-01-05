Given /^I am (?:a|an) (admin)$/ do |role|
  user = User.create(:name => "user")
  login_as user
end