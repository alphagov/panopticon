require 'gds_api/test_helpers/publishing_api'

module RegistrationInfo
  include GdsApi::TestHelpers::PublishingApi

  SEARCH_ROOT = "http://search.dev.gov.uk/mainstream"

  def example_smart_answer
    {
      "need_ids"          => ["102012"],
      "slug"              => "calculate-married-couples-allowance",
      "name"              => "Calculate your Married Couple's Allowance",
      "description"       => "Work out whether you can claim Married Couple's Allowance (MCA) and find out how much you could get taken off your tax bill.",
      "kind"              => "smart-answer",
      "owning_app"        => 'smartanswers',
      "state"             => "live"
    }
  end

  def example_completed_transaction
    {
      "need_ids"          => ["102013"],
      "slug"              => "done/example-transaction",
      "name"              => "Example Transaction Complete",
      "description"       => "This transaction is complete.",
      "kind"              => "completed_transaction",
      "owning_app"        => 'publisher',
      "state"             => "live"
    }
  end

  def example_smart_answer_json
    {artefact: example_smart_answer}.to_json
  end

  def prepare_registration_environment(artefact = example_smart_answer)
    setup_user
    stub_search
  end

  def setup_user
    User.create!(name: "Test", email: "test@example.com", uid: 123)
  end

  def stub_router
    WebMock.stub_request(:any, %r{\A#{Plek.current.find('router-api')}/}).to_return(:status => 200)
  end

  def stub_search
    @fake_search = WebMock.stub_request(:post, "#{SEARCH_ROOT}/documents").to_return(status: 200)
    @fake_search_amend = WebMock.stub_request(:post, %r{^#{Regexp.escape SEARCH_ROOT}/documents/.*$}).to_return(status: 200)
  end

  def stub_search_delete
    @fake_search_delete = WebMock.stub_request(
      :delete,
      "http://rummager.dev.gov.uk/content?link=/#{@artefact.slug}"
    ).to_return(status: 200)
  end

  def artefact_search_url(artefact)
    # The search URL to which amendment requests should be POSTed
    link = "/#{artefact.slug}"
    "#{SEARCH_ROOT}/documents/#{CGI.escape link}"
  end

  def setup_existing_artefact
    @artefact = Artefact.create!(example_smart_answer)
    publishing_api_has_path_reservation_for("/#{@artefact.slug}", @artefact.owning_app)
  end

  def stub_publishing_api
    stub_default_publishing_api_path_reservation
  end
end

World(RegistrationInfo)
