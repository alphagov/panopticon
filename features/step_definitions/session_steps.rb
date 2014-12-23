Given /^I am (?:a|an) (admin)$/ do |role|
  @user = FactoryGirl.create(:odi_user, :name => "user")
  login_as @user
end

Given /^I do not have the "(.*?)" permission$/ do |permission|
  nil # Don't need to do nowt here
end