module RegistrationInfo
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
      "live"              => true
    }
  end

  def example_smart_answer_json
    {artefact: example_smart_answer}.to_json
  end

  def prepare_registration_environment
    setup_user
    stub_search
    stub_router
  end

  def setup_user
    User.create!(name: "Test", email: "test@example.com", uid: 123)
  end

  def stub_search
    @fake_search = WebMock.stub_request(:post, "http://search.test.gov.uk/documents").to_return(status: 200)
    @fake_search_amend = WebMock.stub_request
  end

  def stub_router
    @fake_router = WebMock.stub_request(:put, /http:\/\/router.cluster:8080\/router\/routes\/.*/).to_return(status: 200)
  end

  def setup_existing_artefact
    @artefact = Artefact.create!(example_smart_answer)
  end
end

World(RegistrationInfo)