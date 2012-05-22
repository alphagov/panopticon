module SectionsHelper

  def all_sections(options = {})
    section_tags = TagRepository.load_all(:type => 'section')

    title_counts = Hash.new(0)
    section_tags.each { |tag| title_counts[tag.title] += 1 }

    sections = section_tags.map do |tag|
      # Annotate tags, where necessary, with their IDs
      if title_counts[tag.title] > 1
        display_name = "#{tag.title} [#{tag.tag_id}]"
      else
        display_name = tag.title
      end
      [display_name, tag.tag_id]
    end

    return sections unless options[:except]
    sections.reject { |s| s[1] == options[:except] }
  end

  def parent_section_tab_list
    parent_sections = all_sections.reject do |title, tag_id|
      tag_id =~ %r{/}
    end
    output = parent_sections.map do |title, tag_id|
      content_tag(:li) do
        link_to(title, :section => tag_id)
      end
    end
    safe_join(output)
  end

end
