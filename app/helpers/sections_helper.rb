module SectionsHelper

  def all_sections
    section_tags = TagRepository.load_all(:type => 'section')
    section_tags.map { |tag| [tag.title, tag.tag_id] }
  end
end