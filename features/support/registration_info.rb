module RegistrationInfo

  SEARCH_ROOT = "http://search.#{ENV['GOVUK_APP_DOMAIN']}"

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
    WebMock.stub_request(:post, "#{SEARCH_ROOT}/commit")
           .to_return(:status => 200)
  end

  def artefact_search_url(artefact)
    # The search URL to which amendment requests should be POSTed
    link = "/#{artefact.slug}"
    "#{SEARCH_ROOT}/documents/#{CGI.escape link}"
  end

  def setup_existing_artefact
    Artefact.observers.disable :update_search_observer do
      @artefact = Artefact.create!(example_smart_answer)
    end
  end
end

World(RegistrationInfo)
