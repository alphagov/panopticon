Then /^the "(.*?)" field should be disabled$/ do |field|
  assert page.find("##{field}[disabled]")
end

Then /^the "(.*?)" field should be editable$/ do |field|
  assert page.find("##{field}")
  assert_raises Capybara::ElementNotFound do
    page.find("##{field}[disabled]")
  end
end