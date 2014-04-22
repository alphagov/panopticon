module FilterHelper
  def options_from_tags_for_select(tag_type, selected_value=nil)
    tags = Tag.where(tag_type: tag_type, parent_id: nil)

    tags_with_labels = tags.map {|tag| [tag.title, tag.tag_id] }
    options = [["All", ""]] + tags_with_labels

    options_for_select(options, selected_value || "")
  end

  def options_from_formats_for_select(selected_value=nil)
    formats_with_labels = Artefact::ODI_FORMATS.sort.map {|format|
      [ format.underscore.humanize, format ]
    }
    options = [["All", ""]] + formats_with_labels

    options_for_select(options, selected_value || "")
  end

  def options_from_states_for_select(selected_value=nil)
    states_with_labels = Artefact::STATES.sort.map {|state|
      [ state.humanize, state ]
    }
    options = [["All", ""]] + states_with_labels

    if selected_value.nil?
      selected_value = "live"
    end

    options_for_select(options, selected_value || "")
  end
end
