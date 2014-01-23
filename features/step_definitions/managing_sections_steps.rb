Then /^I should see the link to manage sections$/ do
  xpath = "//a[@href='#{sections_path}']"
  assert page.has_xpath?(xpath)
end

Given /^I have the "(.*?)" permission$/ do |permission|
  @user.permissions << permission
end

When /^I follow the link to manage sections$/ do
  visit sections_path
end

When /^I click the Add new section link$/ do
  click_link 'Add new section'
end

Then /^I should see the Add new section form$/ do
  assert page.has_css?('form.section')
end

When /^I fill in the form for a new section$/ do
  fill_in "Title", with: "Title"
  fill_in "Link", with: "http://www.example.com"
  fill_in "Description", with: "Foo bar rubbish"
  fill_in "Section ID", with: "foo"
  
  click_button "Save"
end

Then /^I should get redirected to the section list$/ do
  assert_equal sections_url, page.current_url
end

Then /^I should see a message saying my section has been created$/ do
  assert_match /Section created!/, page.body
end

Then /^I should not see the Add new section link$/ do
  assert_no_match /Add new section/, page.body
end

Then /^I should see my section in the list$/ do
  assert_match /Title/, page.body
end

When /^I visit the page to add a new section$/ do
  visit new_section_path
end

When /^I add an image to upload$/ do
  @filename = "asset.jpg"
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => "http://path/to/#{@filename}")

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
  
  attach_file "section_hero_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
end

Then /^my section should have the image associated with it$/ do
  assert_equal "http://path/to/#{@filename}", Section.first.hero_image.file_url
end

Given /^a section with an image already exists$/ do
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => 'http://path/to/asset.jpg')

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
    
  visit new_section_path
  
  fill_in "Title", with: "Title"
  fill_in "Link", with: "http://www.example.com"
  fill_in "Description", with: "Foo bar rubbish"
  fill_in "Section ID", with: "foo"
  attach_file "section_hero_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
  click_button "Save"
end

When /^I access the page for that section$/ do
  visit sections_path
  click_link "Title"
end

When /^I specify a new image$/ do
  @filename = "asset2.jpg"
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => "http://path/to/#{@filename}")

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
  
  attach_file "section_hero_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
  click_button "Save"
end

When /^I click the remove image checkbox on the section page$/ do
  check "section_remove_image"
  click_button "Save"
end

Then /^my section should not have an image associated with it$/ do
  assert_nil Section.first.hero_image
end