class DeleteRpaSpecialistSector < Mongoid::Migration
  def self.up
    parent = Tag.by_tag_id('farming-food-inspections', 'specialist_sector')
    children = Tag.where(tag_type: 'specialist_sector', parent_id: parent.tag_id)

    ([parent] + children).each do |tag|
      tag.destroy
      puts "Deleted #{tag.tag_id}"
    end
  end

  def self.down
    @parent = Tag.create!(tag_id: 'farming-food-inspections', title: 'Farming and food inspections', tag_type: 'specialist_sector')
    puts "Re-created #{@parent.tag_id}"

    children_to_recreate.each do |(title,slug)|
      Tag.create!(tag_id: "#{@parent.tag_id}/#{slug}", title: title, tag_type: 'specialist_sector', parent_id: @parent.tag_id)
      puts "Re-created #{@parent.tag_id}/#{slug}"
    end
  end

  private

  def self.children_to_recreate
    [
      ["Fresh produce", "fresh-produce"],
      ["Livestock identification", "livestock-identification"],
      ["Meat labelling and traceability", "meat-labelling-traceability"],
      ["Sugar", "sugar"],
    ]
  end
end
