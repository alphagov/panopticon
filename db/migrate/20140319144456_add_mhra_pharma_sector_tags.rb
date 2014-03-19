class AddMhraPharmaSectorTags < Mongoid::Migration

  def self.pharma_sector_topics
    [
      { title: 'Advertising of medicines', slug: 'advertising-medicines'},
      { title: 'Applications and submissions', slug: 'applications-submissions'},
      { title: 'Approved products', slug: 'approved-products'},
      { title: 'Clinical trials', slug: 'clinical-trials'},
      { title: 'Drug Analysis Prints', slug: 'drug-analysis-prints'},
      { title: 'Drug and device alerts', slug: 'drug-device-alerts'},
      { title: 'Fees', slug: 'fees'},
      { title: 'Good Clinical Practice', slug: 'good-clinical-practice'},
      { title: 'Good Laboratory Practice', slug: 'good-laboratory-practice'},
      { title: 'Good Manufacturing and Distribution Practice', slug: 'good-manufacturing-practice'},
      { title: 'Good Pharmacovigilance Practice', slug: 'good-pharmacovigilance-practice'},
      { title: 'Herbal and homeopathic medicines', slug: 'herbal-homeopathic-medicines'},
      { title: 'Importing and exporting medicines', slug: 'importing-exporting-medicines'},
      { title: 'Labels, patient information leaflets and packaging for medicines', slug: 'labels-packaging-for-medicines'},
      { title: 'Legal status and reclassification', slug: 'legal-status-reclassification'},
      { title: 'Maintaining a marketing authorisation', slug: 'maintaining-marketing-authorisation'},
      { title: 'Manufacturing and wholesaling', slug: 'manufacturing-wholesaling'},
      { title: 'New marketing authorisations', slug: 'new-marketing-authorisations'},
      { title: 'Public Assessment Reports', slug: 'public-assessment-reports'},
      { title: 'Safety reporting and pharmacovigilance', slug: 'safety-reporting'},
      { title: 'Variations to licences', slug: 'variations-to-licences'},
    ]
  end

  def self.create_topics_for_parent(parent, topics)
    topics.each do |topic|
      created = Tag.create!(tag_id: "#{parent.tag_id}/#{topic[:slug]}", title: topic[:title], tag_type: 'specialist_sector', parent_id: parent.tag_id)
      puts "Created #{created.tag_id}"
    end
  end

  def self.destroy_topics_for_parent(parent_id)
    parent_tag = Tag.by_tag_id(parent_id)
    parent_tag.destroy
    puts "Deleted #{parent_tag.tag_id}"

    Tag.where(parent_id: parent_id).each do |tag|
      tag.destroy
      puts "Deleted #{tag.tag_id}"
    end
  end

  def self.up
    pharma_tag = Tag.create!(tag_type: 'specialist_sector', tag_id: 'pharmaceutical-industry', title: 'Pharmaceutical industry')
    puts "Created #{pharma_tag.tag_id}"

    create_topics_for_parent(pharma_tag, pharma_sector_topics)
  end

  def self.down
    destroy_topics_for_parent('pharmaceutical-industry')
  end
end
