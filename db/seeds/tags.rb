#######
#
# This file will be run on every deploy, so make sure the changes here are non-destructive
#
#######

TagRepository.put(:tag_id => 'businesslink', :title => 'Business Link', :tag_type => 'legacy_source')
TagRepository.put(:tag_id => 'directgov', :title => 'Directgov', :tag_type => 'legacy_source')

TagRepository.put(tag_type: "section", tag_id: "disabilities", title: "Disabled people", description: "Includes your rights, benefits, carers and the Equality Act")
parent = Tag.where(tag_id: "disabilities").first
TagRepository.put(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/benefits",  title: "Benefits and financial help",        description: "Includes Disability Living Allowance, Employment and Support Allowance and Attendance Allowance")
TagRepository.put(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/carers",    title: "Carers",                             description: "Includes Carer's Allowance, disabled children and disability day care centres")
TagRepository.put(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/rights",    title: "Disability rights",                  description: "Disability rights under the Equality Act 2010")
TagRepository.put(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/work",      title: "Work and disabled people",           description: "Includes recruitment and disabled people, reasonable adjustments at work and Access to Work")
TagRepository.put(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/equipment", title: "Disability equipment and transport", description: "Includes Disabled Students Allowances, Blue Badge and disabled access")