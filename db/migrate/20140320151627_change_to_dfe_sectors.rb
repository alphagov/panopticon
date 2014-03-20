class ChangeToDfeSectors < Mongoid::Migration
  def self.up
    parents = %w{childrens-services schools-colleges}

    parents.each do |parent|
      created = Tag.create!(tag_id: "#{parent}/safeguarding-children", title: 'Safeguarding children', tag_type: 'specialist_sector', parent_id: parent)
      puts "Created #{created.tag_id}"
    end

    destroyed = Tag.by_tag_id('schools-colleges/procurement')
    destroyed.destroy
    puts "Destroyed #{destroyed.tag_id}"
  end

  def self.down
    parents = %w{childrens-services schools-colleges}

    parents.each do |parent|
      destroyed = Tag.by_tag_id("#{parent}/safeguarding-children")
      destroyed.destroy
      puts "Destroyed #{destroyed.tag_id}"
    end

    created = Tag.create!(tag_id: 'schools-colleges/procurement', title: 'Procurement', tag_type: 'specialist_sector', parent: 'schools-colleges')
    puts "Created #{created.tag_id}"
  end
end
