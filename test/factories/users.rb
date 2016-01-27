FactoryGirl.define do
  factory :user_with_manage_tags_permission, parent: :user do
    permissions %w(signin manage_tags)
  end
end
