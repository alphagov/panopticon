Given /^I am (?:a|an) (admin)$/ do |role|
  user = FactoryGirl.create(:user, :name => "user")
  login_as user
end

Given /^I am a user who can edit tags$/ do
  user = create(:user_with_manage_tags_permission)
end
