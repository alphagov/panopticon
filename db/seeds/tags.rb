#######
#
# This file will be run on every deploy, so make sure the changes here are non-destructive
#
#######

TagRepository.put(:tag_id => 'businesslink', :title => 'Business Link', :tag_type => 'legacy_source')
TagRepository.put(:tag_id => 'directgov', :title => 'Directgov', :tag_type => 'legacy_source')

old_registry_office_tag = Tag.where(:tag_id => 'births-deaths-marriages/registry-offices').first
if old_registry_office_tag
  old_registry_office_tag.tag_id = 'births-deaths-marriages/register-offices'
  old_registry_office_tag.save!
end