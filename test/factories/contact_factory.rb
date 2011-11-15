FactoryGirl.define do
  factory :contact do
    sequence(:name) { |n| "Contact #{n}" }
    sequence :contactotron_id
  end
end
