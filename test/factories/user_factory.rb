FactoryGirl.define do
  factory :odi_user, parent: :user do
    before(:create) do
      Tag.create(title: "Writer", tag_type: "person", tag_id: "writers")
    end
  end
end