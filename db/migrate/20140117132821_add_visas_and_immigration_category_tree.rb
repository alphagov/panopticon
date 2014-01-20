class AddVisasAndImmigrationCategoryTree < Mongoid::Migration
  def self.up
    Tag.create(tag_id: 'visas-immigration', tag_type: 'section', title: "Visas and immigration", description: "Visas, asylum and sponsorship", parent_id: nil)

    self.children.each do |slug, title, description|
      child_tag_id = "visas-immigration/#{slug}"
      unless child = Tag.by_tag_id(child_tag_id)
        child = Tag.create(tag_id: child_tag_id, tag_type: 'section', title: title, description: description, parent_id: 'visas-immigration')
        puts "Created child #{child.title}"
      end
    end
  end

  def self.down
    Tag.any_in(tag_id: ["visas-immigration"] + self.children.map { |x, _, _| "visas-immigration/#{x}" }).delete
  end

private

  def self.children
    [
      ["asylum", "Asylum", "Asylum process, home office travel documents"],
      ["employers-sponsorship", "Employers' sponsorship", "Eligibility, licences, supporting evidence, shortage occupation list"],
      ["family-visas", "Joining family visas", "EEA family permits, getting married in the UK, split settled persons"],
      ["your-visa", "Managing your visa", "Your rights, biometric permits, extend your visas, get your documents returned"],
      ["study-visas", "Study visas", "Educational sponsorship, switching from study to work"],
      ["transit-visas", "Transit visas", "Airside, landside, common travel area"],
      ["visit-visas", "Visit visas", "Tourism and visiting friends"],
      ["working-visas", "Working visas", "European nationals, sponsorship, switching employers"]
    ]
  end
end
