module SectionsHelper

  # Load all the section tags and return them in a form suitable for
  # use with the rails form helpers to build a select box.
  #
  # To force a tag to be excluded pass in the +options+ hash with a
  # key of :except
  def all_sections(options = {})
    section_tags = Tag.where(:tag_type => 'section')

    sections = options_for_sections(section_tags)

    return sections unless options[:except]
    sections.reject { |s| s[1] == options[:except] }
  end

  def options_for_tags_of_type(tag_type)
    Tag.where(:tag_type => tag_type).order(:title).map {|t| [t.title, t.tag_id]}
  end

  # Convert an array of sections into a nested array suitable for
  # using with the rails form helpers' select box tools.
  #
  # The way that tags are nested can lead to ambiguous titles (eg. two
  # independent sections called 'Children' with different parents).
  # These are then distinguished by displaying the tag_id which will
  # reveal the parentage.
  def options_for_sections(section_tags)
    title_counts = Hash.new(0)
    section_tags.each { |tag| title_counts[tag.title] += 1 }

    section_tags.map do |tag|
      # Annotate tags, where necessary, with their IDs
      if title_counts[tag.title] > 1
        display_name = "#{tag.title} [#{tag.tag_id}]"
      else
        display_name = tag.title
      end
      [display_name, tag.tag_id]
    end
  end

  def parent_sections
    parent_sections = all_sections.reject do |title, tag_id|
      tag_id =~ %r{/}
    end
  end

  def parent_section_tab_list(options)
    sections = [["All", "all"]] + parent_sections

    output = sections.map do |title, tag_id|
      css_class = ""
      if tag_id == options[:current].downcase
        css_class = "active"
      end
      content_tag(:li, :class => css_class) do
        link_to(title, :section => tag_id)
      end
    end
    safe_join(output)
  end

end
