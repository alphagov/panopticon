Given /^I am (?:a|an) (admin)$/ do |role|
  user = FactoryGirl.create(:user, :name => "user")
  login_as user
end

