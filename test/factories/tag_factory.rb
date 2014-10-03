FactoryGirl.define do
  factory :odi_role, class: Tag do
    title "ODI"
    tag_type "role"
    tag_id "odi"
  end
  
  factory :dapaas_role, class: Tag do
    title "DaPaaS"
    tag_type "role"
    tag_id "dapaas"
  end
  
end