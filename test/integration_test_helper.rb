require_relative 'test_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.use_default_driver
  end

  def put_json(path, attrs, headers = {})
    # Rack::Test put method calls to_json on whatever body you pass.
    # This is different to the post method.  Go figure.
    put path, attrs, {"Content-Type" => "application/json"}.merge(headers)
  end

  def login_as(user)
    GDS::SSO.test_user = user
  end

  def login_as_user_with_permission(permission)
    user = create(:user, permissions: ['signin', permission])
    login_as(user)
  end

  def add_need_id(need_id)
    # needs ids are entered in a tagsinput component
    # which has a mask. hence, this is needed.
    page.execute_script(%Q<$("#tagsinput-text-box").val("#{need_id}")>)
    within '#user-need' do
      click_link 'Add Maslow need ID'
      # the click above triggers a page javascript
      # so an explicit wait is needed, or else capybara
      # doesn't wait before adding another need_id, which
      # happens too fast.
      sleep 0.5
    end
  end

end
