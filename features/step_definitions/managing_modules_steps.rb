Then /^I should see the link to manage modules$/ do
  xpath = "//a[@href='#{section_modules_path}']"
  assert page.has_xpath?(xpath)
end

When /^I click the link to manage modules$/ do
  visit section_modules_path
end

When /^I click the link to add a new module$/ do
  click_link 'Add new module'
end

Then /^I should see the module form$/ do
  assert page.has_css?('form.section_module')
end

When /^I fill out the form for a new module$/ do
  fill_in "Title", with: "My module title"
  select "Text", from: "Type"
  fill_in "Link", with: "http://www.example.com"
  fill_in "Text", with: "Foo bar rubbish"
  select "Red", from: "Colour"
  
  click_button "Save"
end

Then /^I should get redirected to the module list$/ do
  assert_equal section_modules_url, page.current_url
end

Then /^I should see a message saying my module has been created$/ do
  assert_match /Module created!/, page.body
end

Then /^I should see my module in the list$/ do
  assert_match /My module title/, page.body
end

When /^I visit the page to add a new module$/ do
  visit new_section_module_path
end

When /^I add a module image to upload$/ do
  @filename = "asset.jpg"
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => "http://path/to/#{@filename}")

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
  
  attach_file "section_module_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
end

When /^I fill in the form for a new module$/ do
  fill_in "Title", with: "Title"
  select "Image", from: "Type"
  fill_in "Link", with: "http://www.example.com"
  click_button "Save"
end

Then /^my module should have the image associated with it$/ do
  assert_equal "http://path/to/#{@filename}", SectionModule.first.image.file_url
end

Given /^a module with an image already exists$/ do
  visit new_section_module_path
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => 'http://path/to/asset.jpg')

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
      
  fill_in "Title", with: "Title"
  select "Image", from: "Type"
  fill_in "Link", with: "http://www.example.com"
  attach_file "section_module_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
  click_button "Save"
end

When /^I access the page for that module$/ do
  visit section_modules_path
  click_link "Title"
end

When /^I specify a new module image$/ do
  @filename = "asset2.jpg"
  asset = OpenStruct.new(:id => 'http://asset-manager.dev/assets/an_image_id', :file_url => "http://path/to/#{@filename}")

  GdsApi::AssetManager.any_instance.stubs(:create_asset).returns(asset)
  GdsApi::AssetManager.any_instance.stubs(:asset).with("an_image_id").returns(asset)
  
  attach_file "section_module_image", File.expand_path(File.join('features', 'fixtures', 'asset.jpg'))
  click_button "Save"
end

When /^I click the remove image checkbox on the module page$/ do
  check "section_module_remove_image"
  click_button "Save"
end

Then /^my module should not have an image associated with it$/ do
  assert_nil SectionModule.first.image
end