class FixPopulationScreeningTagParents < Mongoid::Migration
  OLD_PARENT = 'nhs-population-screening-programmes'

  def self.up
    Tag.where(:tag_type => "specialist_sector", :parent_id => OLD_PARENT).each do |tag|
      new_parent_id = tag.parent_id.sub(/\Anhs-/, '')
      puts "Updating #{tag.tag_id} parent #{tag.parent_id} -> #{new_parent_id}"
      tag.parent_id = new_parent_id
      tag.save!
    end
  end
end
