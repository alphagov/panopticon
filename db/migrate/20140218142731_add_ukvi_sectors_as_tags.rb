class AddUkviSectorsAsTags < Mongoid::Migration

  def self.ukvi_topics
    [
      {slug: 'asylum-policy', title: 'Asylum policy'},
      {slug: 'commerical-casework-guidance', title: 'Business and commercial caseworker guidance'},
      {slug: 'enforcement', title: 'Enforcement'},
      {slug: 'entry-clearance-guidance', title: 'Entry clearance guidance'},
      {slug: 'european-casework-instructions', title: 'European casework instructions'},
      {slug: 'immigration-directorate-instructions', title: 'Immigration directorate instructions'},
      {slug: 'modernised-guidance', title: 'Modernised guidance'},
      {slug: 'nationality-instructions', title: 'Nationality instructions'},
      {slug: 'non-compliance-biometric-registration', title: 'Non-compliance with the biometric registration regulations'},
      {slug: 'stateless-guidance', title: 'Stateless guidance'}
    ]    
  end


  def self.up
    parent_tag = Tag.create!(tag_id: 'immigration-operational-guidance', title: 'Visas and immigration operational guidance', tag_type: 'specialist_sector')
    
    ukvi_topics.each do |topic|
      Tag.create!(tag_id: "#{parent_tag.tag_id}/#{topic[:slug]}", title: topic[:title], tag_type: 'specialist_sector', parent_id: parent_tag.tag_id)
    end
  end

  def self.down
    Tag.by_tag_id('immigration-operational-guidance').destroy

    ukvi_topics.each do |topic|
      Tag.by_tag_id("immigration-operational-guidance/#{topic[:slug]}").destroy
    end
  end
end
