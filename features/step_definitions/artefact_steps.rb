When /^I am editing "(.*)"$/ do |name|
  visit edit_artefact_path(Artefact.find_by_name(name))
end

When /^I add "(.*)" as a related item$/ do |name|
  within_fieldset 'Related items' do
    within :xpath, './/select[not(option[@selected])]' do
      select name
    end
  end
end
