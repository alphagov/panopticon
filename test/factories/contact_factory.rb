FactoryGirl.define do
  factory :contact do
    sequence(:name) { |n| "Contact #{n}" }
  end
end
