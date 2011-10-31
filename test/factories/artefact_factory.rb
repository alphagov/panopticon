FactoryGirl.define do
  factory :artefact do
    sequence(:name) { |n| "Artefact #{n}" }
    sequence(:slug) { |n| "artefact-#{n}" }
    kind            Artefact::FORMAT.first
    owning_app      'publisher'
  end
end
