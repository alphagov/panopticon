module RegistrationInfo

  SEARCH_ROOT = "http://search.dev.gov.uk"

  def example_person
    {
      "need_id"           => 2012,
      "slug"              => "bob-fish",
      "name"              => "Bob Fish",
      "kind"              => "person",
      "owning_app"        => 'publisher',
      "state"             => "live"
    }
  end

  def example_news_item
    {
      "need_id"           => 2013,
      "slug"              => "news-item",
      "name"              => "News Item",
      "description"       => "News!",
      "kind"              => "news",
      "link"              => "/news-item",
      "indexable_content" => "",
      "owning_app"        => 'publisher',
      "state"             => "live"
    }
  end

  def example_news_item_json
    {artefact: example_news_item}.to_json
  end

  def prepare_registration_environment(artefact = example_news_item)
    setup_user
    stub_search
  end

  def setup_user
    User.create!(name: "Test", email: "test@example.com", uid: 123)
  end

  def stub_search
    @fake_search = WebMock.stub_request(:post, "#{SEARCH_ROOT}/documents").to_return(status: 200)
    @fake_search_amend = WebMock.stub_request(:post, %r{^#{Regexp.escape SEARCH_ROOT}/documents/.*$}).to_return(status: 200)
  end

  def stub_search_delete
    @fake_search_delete = WebMock.stub_request(:delete, artefact_search_url(@artefact)).to_return(status: 200)
    WebMock.stub_request(:post, "http://search.dev.gov.uk/commit")
           .to_return(:status => 200)
  end

  def artefact_search_url(artefact)
    # The search URL to which amendment requests should be POSTed
    link = "/#{artefact.slug}"
    "#{SEARCH_ROOT}/documents/#{CGI.escape link}"
  end

  def setup_existing_artefact
    Artefact.observers.disable :update_search_observer do
      @artefact = Artefact.create!(example_person)
    end
  end
end

World(RegistrationInfo)
