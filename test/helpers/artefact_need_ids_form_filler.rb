module ArtefactNeedIdsFormFiller
  def add_need_id(need_id)
    # needs ids are entered in an input field
    # which has a mask. hence, this is needed.
    page.execute_script(%Q<$("#artefact_need_ids").val("#{need_id}")>)
    within '#user-need' do
      click_link 'Add Maslow Need ID'
      # the click above triggers a page javascript
      # so an explicit wait is needed, or else capybara
      # doesn't wait before adding another need_id, which
      # happens too fast.
      sleep 0.5
    end
  end
end
