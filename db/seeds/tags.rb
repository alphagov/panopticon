#######
#
# This file will be run on every deploy, so make sure the changes here are non-destructive
#
#######

TagRepository.put(:tag_id => 'businesslink', :title => 'Business Link', :tag_type => 'legacy_source')
TagRepository.put(:tag_id => 'directgov', :title => 'Directgov', :tag_type => 'legacy_source')

old_tag_id = 'births-deaths-marriages/registry-offices'
new_tag_id = 'births-deaths-marriages/register-offices'

old_registry_office_tag = Tag.where(:tag_id => old_tag_id).first
if old_registry_office_tag
  old_registry_office_tag.tag_id = new_tag_id
  old_registry_office_tag.save!
end

new_registry_office_tag = Tag.where(:tag_id => new_tag_id).first

Artefact.all.any_in(:tag_ids => [old_tag_id]).each do |artefact|
  artefact.tag_ids = artefact.tag_ids.map do |tag_id| 
    if tag_id == old_tag_id
      new_registry_office_tag.tag_id
    else
      tag_id
    end
  end

  artefact.save!
end