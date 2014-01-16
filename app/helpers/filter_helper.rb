module FilterHelper
  def options_from_tags_for_select(tag_type, selected_value=nil)
    tags = Tag.where(tag_type: tag_type, parent_id: nil)

    tags_with_labels = tags.map {|tag| [tag.title, tag.tag_id] }
    options = [["All", nil]] + tags_with_labels

    options_for_select(options, selected_value)
  end

  def options_from_formats_for_select(selected_value=nil)
    formats_with_labels = Artefact::FORMATS.sort.map {|format|
      [ format.underscore.humanize, format ]
    }
    options = [["All", nil]] + formats_with_labels

    options_for_select(options, selected_value)
  end

  def options_from_states_for_select(selected_value=nil)
    states_with_labels = Artefact::STATES.sort.map {|state|
      [ state.humanize, state ]
    }
    options = [["All", nil]] + states_with_labels

    options_for_select(options, selected_value)
  end
end
