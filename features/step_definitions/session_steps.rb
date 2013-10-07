Given /^I am (?:a|an) (admin)$/ do |role|
  user = FactoryGirl.create(:odi_user, :name => "user")
  login_as user
end