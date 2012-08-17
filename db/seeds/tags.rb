#######
#
# This file will be run on every deploy, so make sure the changes here are non-destructive
#
#######

TagRepository.put(:tag_id => 'businesslink', :title => 'Business Link', :tag_type => 'legacy_source')
TagRepository.put(:tag_id => 'directgov', :title => 'Directgov', :tag_type => 'legacy_source')
