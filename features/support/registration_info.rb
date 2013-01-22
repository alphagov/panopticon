module RegistrationInfo

  SEARCH_ROOT = "http://search.dev.gov.uk"
  ROUTER_ROOT = "http://router.cluster:8080"

  def example_smart_answer
    {
      "need_id"           => 2012,
      "slug"              => "calculate-married-couples-allowance",
      "name"              => "Calculate your Married Couple's Allowance",
      "description"       => "Work out whether you can claim Married Couple's Allowance (MCA) and find out how much you could get taken off your tax bill.",
      "kind"              => "smart-answer",
      "section"           => "money-and-tax",
      "subsection"        => "tax",
      "link"              => "/calculate-married-couples-allowance",
      "indexable_content" => "You can use this calculator to work out if you qualify for Married Couple's Allowance, and how much you might get. You need to be married or in a civil partnership to claim. Were you or your partner born on or before 6 April 1935? You must be married or in a civil partnership to qualify. Did you marry before 5 December 2005? Before this date the husband's income is used to work out your allowance, after this date it's the income of the highest earner. What's the husband's date of birth? We need your date of birth to work out your personal allowance (how much of your income is tax-free). What's the highest earner's date of birth? We need your date of birth to work out your personal allowance (how much of your income is tax-free). What's the husband's yearly income? Add up your taxable income, eg earnings, pensions and any taxable benefits, eg Employment and Support Allowance. What's the highest earner's yearly income? Add up your taxable income, eg earnings, pensions and any taxable benefits, eg Employment and Support Allowance. Contact HM Revenue & Customs to claim. HM Revenue & Customs Telephone 0845 300 0627 Textphone 0845 302 1408 This result is an estimate based on your answers. Contact HM Revenue & Customs to claim. HM Revenue & Customs Telephone 0845 300 0627 Textphone 0845 302 1408 This result is an estimate based on your answers. Sorry, you don't qualify for Married Couple's Allowance.",
      "owning_app"        => 'smart-answers',
      "state"             => "live"
    }
  end

  def example_completed_transaction
    {
      "need_id"           => 2013,
      "slug"              => "done/example-transaction",
      "name"              => "Example Transaction Complete",
      "description"       => "This transaction is complete.",
      "kind"              => "completed_transaction",
      "section"           => "money-and-tax",
      "subsection"        => "tax",
      "link"              => "/done/example-transaction",
      "indexable_content" => "",
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
    stub_router(artefact)
  end

  def setup_user
    User.create!(name: "Test", email: "test@example.com", uid: 123)
  end

  def stub_search
    @fake_search = WebMock.stub_request(:post, "#{SEARCH_ROOT}/documents").to_return(status: 200)
    @fake_search_amend = WebMock.stub_request(:post, %r{^#{Regexp.escape SEARCH_ROOT}/documents/.*$}).to_return(status: 200)
  end

  def stub_router(artefact = nil)
    WebMock.stub_request(:put, %r{^#{ROUTER_ROOT}/router/applications/.*$}).
        with(:body => { "backend_url" => %r{^.*\.dev\.gov\.uk$} }).
        to_return(:status => 200, :body => "{}", :headers => {})

    # catch-all
    WebMock.stub_request(:put, %r{^#{ROUTER_ROOT}/router/routes/.*$}).
          with(:body => {"application_id" => /.+/, "route_type" => "full"}).
          to_return(:status => 200, :body => "{}", :headers => {})

    # so that we can assert on them later
    @fake_routers = [OpenStruct.new(artefact), @artefact, @related_artefact].reject(&:nil?).map do |artefact|
      WebMock.stub_request(:put, "#{ROUTER_ROOT}/router/routes/#{artefact.slug}").
            with(:body => { "application_id" => artefact.owning_app, "route_type" => "full"}).
            to_return(:status => 200, :body => "{}", :headers => {})
    end
  end

  def stub_search_delete
    @fake_search_delete = WebMock.stub_request(:delete, artefact_search_url(@artefact)).to_return(status: 200)
    WebMock.stub_request(:post, "http://search.dev.gov.uk/commit")
           .to_return(:status => 200)
  end

  def stub_router_delete
    # so that we can assert on them later
    @fake_router_deletes = [@artefact].map do |artefact|
      WebMock.stub_request(:delete, "#{ROUTER_ROOT}/router/routes/#{artefact.slug}").
            to_return(:status => 200, :body => "{}", :headers => {})
    end
  end

  def artefact_search_url(artefact)
    # The search URL to which amendment requests should be POSTed
    link = "/#{artefact.slug}"
    "#{SEARCH_ROOT}/documents/#{CGI.escape link}"
  end

  def setup_existing_artefact
    Artefact.observers.disable :update_search_observer, :update_router_observer do
      @artefact = Artefact.create!(example_smart_answer)
    end
  end
end

World(RegistrationInfo)
