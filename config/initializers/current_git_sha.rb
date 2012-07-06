revision = `cat #{Rails.root}/REVISION`.chomp
if revision.blank?
  CURRENT_RELEASE_SHA = "development"
else
  CURRENT_RELEASE_SHA = revision[0..10] # Just get the short SHA
end