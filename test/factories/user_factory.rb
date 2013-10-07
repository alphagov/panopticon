FactoryGirl.define do
  factory :odi_user, parent: :user do
    before(:create) do
      Tag.create(title: "Staff", tag_type: "person", tag_id: "people/staff")
    end
  end
end