namespace :migrate do
  desc "Populate CuratedList with data extracted from text file in Rummager"
  task :populate_curated_list do
    Mongoid.load!("config/mongoid.yml")

    class CuratedList
      include Mongoid::Document
      include Mongoid::Timestamps

      field "slug", type: String
      field "artefact_ids", type: Array, default: []

      index "slug"

      validates :slug, presence: true, uniqueness: true
    end

    class Artefact
      include Mongoid::Document
      include Mongoid::Timestamps

      field "slug", type: String
    end

    curated_lists = {
      "neighbourhoods" => [
        "uk-online-centre-internet-access-computer-training",
        "organise-fete-street-party",
        "noise-pollution-road-train-plane",
        "control-dog-public",
        "report-litter",
        "report-abandoned-vehicle",
        "join-library",
        "garden-bonfires-rules",
        "find-out-about-local-park",
        "book-computer-at-library",
        "find-a-community-support-group-or-organisation",
        "check-drinking-water-quality"
      ],
      "housing" => [
        "housing-benefit",
        "council-tax-benefit",
        "council-housing",
        "apply-for-council-housing",
        "pay-council-tax",
        "council-tax-bands",
        "warm-front-scheme",
        "mortgage-rescue-scheme",
        "private-renting",
        "affordable-home-ownership-schemes",
        "tenancy-deposit-protection",
        "rubbish-collection-day",
      ],
      "crime-and-justice" => [
        "jury-service",
        "report-crime-anti-social-behaviour",
        "life-in-prison",
        "become-magistrate",
        "staying-in-touch-with-someone-in-prison",
        "legal-aid",
        "report-domestic-abuse",
        "courts",
        "pay-court-fine-online",
        "get-support-as-a-victim-of-crime",
        "arrested-your-rights",
        "going-to-court-victim-witness"
      ],
      "education" => [
        "apply-for-student-finance-2012-13",
        "student-finance-calculator",
        "school-term-holiday-dates",
        "national-curriculum",
        "find-nursery-school-place",
        "apply-for-primary-school-place",
        "apply-for-secondary-school-place",
        "career-development-loans",
        "1619-bursary-fund",
        "courses-qualifications",
        "grant-bursary-adult-learners",
      ],
      "work" =>[
        "find-job",
        "jobseekers-allowance",
        "calculate-redundancy-pay",
        "your-right-to-minimum-wage",
        "taking-annual-leave-your-rights",
        "employment-contracts-and-conditions",
        "redundant-your-rights",
        "statutory-sick-pay-ssp",
        "crb-criminal-records-bureau-check",
        "national-insurance-number",
        "statutory-maternity-pay",
        "looking-for-work-if-youre-disabled"
      ],
      "family" => [
        "order-copy-birth-death-marriage-certificate",
        "register-birth",
        "divorce",
        "after-a-death",
        "register-offices",
        "marriages-civil-partnerships",
        "wills-probate-inheritance",
        "maternity-allowance",
        "carers-allowance",
        "qualify-tax-credits-quick-questionnaire",
        "paternityleave",
        "find-before-after-school-childcare",
      ],
      "money-and-tax" => [
        "benefits-calculator",
        "income-support",
        "national-insurance",
        "claim-tax-credits",
        "tax-credits-calculator",
        "crisis-loans",
        "dla-disability-living-allowance-guide",
        "state-pension",
        "file-your-self-assessment-tax-return",
        "community-care-grant",
        "income-tax-rates",
        "pension-credit",
      ],
      "driving" => [
        "car-tax-disc-vehicle-licence",
        "calculate-vehicle-tax-rates",
        "book-a-driving-theory-test",
        "book-practical-driving-test",
        "change-address-driving-licence",
        "check-mot-status-vehicle",
        "vehicle-tax-rate-tables",
        "apply-online-to-replace-a-driving-licence",
        "change-name-driving-licence",
        "apply-first-provisional-driving-licence",
        "change-photo-driving-licence",
        "apply-blue-badge",
      ],
      "travel" => [
        "apply-renew-passport",
        "plan-your-journey",
        "local-road-closures-diversions",
        "passport-quick",
        "hand-luggage-restrictions-at-uk-airports",
        "apply-renew-european-health-insurance-card",
        "free-bus-passes-in-england",
        "transport-disabled",
        "state-pension-if-you-retire-abroad",
        "moving-abroad",
        "bringing-food-animals-plants-into-uk"
      ],
      "life-in-the-uk" => [
        "petition-government",
        "search-local-archives",
        "register-to-vote",
        "bank-holidays",
        "becoming-a-british-citizen",
        "rights-disabled-person",
        "make-will",
        "volunteering",
        "equality-act-2010",
        "book-life-in-uk-test",
        "power-of-attorney",
        "organise-citizenship-ceremony-council",
      ]
    }
    curated_lists.each do |list_slug, artefact_slugs|
      curated_list = CuratedList.create(slug: list_slug)
      # Do this the long-way-round to get ordering of items correct
      artefact_slugs.each do |artefact_slug|
        if artefact = Artefact.where(slug: artefact_slug).first
          curated_list.artefact_ids << artefact.id
        end
      end
      curated_list.save!
    end
  end
end