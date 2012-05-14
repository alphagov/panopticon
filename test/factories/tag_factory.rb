FactoryGirl.define do
  factory :tag do
    sequence(:tag_id) { |n| "crime-and-justice/the-police-#{n}" }
    sequence(:title) { |n| "The title #{n}" }
    tag_type "section"
  end
end
