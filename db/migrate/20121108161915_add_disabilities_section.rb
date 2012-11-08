class AddDisabilitiesSection < Mongoid::Migration
  def self.up
    parent = Tag.create!(tag_type: "section", tag_id: "disabilities", title: "Disabled people", description: "Includes your rights, benefits, carers and the Equality Act")
    Tag.create!(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/benefits",  title: "Benefits and financial help",        description: "Includes Disability Living Allowance, Employment and Support Allowance and Attendance Allowance")
    Tag.create!(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/carers",    title: "Carers",                             description: "Includes Carer's Allowance, disabled children and disability day care centres")
    Tag.create!(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/rights",    title: "Disability rights",                  description: "Disability rights under the Equality Act 2010")
    Tag.create!(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/work",      title: "Work and disabled people",           description: "Includes recruitment and disabled people, reasonable adjustments at work and Access to Work")
    Tag.create!(tag_type: "section", parent_id: parent.tag_id, tag_id: "disabilities/equipment", title: "Disability equipment and transport", description: "Includes Disabled Students Allowances, Blue Badge and disabled access")
  end

  def self.down
  end
end