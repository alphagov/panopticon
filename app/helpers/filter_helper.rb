module FilterHelper
  def options_from_formats_for_select(selected_value=nil)
    non_panopticon_formats = Artefact::FORMATS_BY_DEFAULT_OWNING_APP.except('panopticon').values.flatten
    formats_with_labels = non_panopticon_formats.sort.map {|format|
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

    options_for_select(options, selected_value || "")
  end

  def options_from_owning_apps_for_select(selected_value=nil)
    owning_apps = Artefact.all.distinct(:owning_app)
    owning_apps.delete("panopticon")

    owning_apps_with_labels = owning_apps.sort.map {|owning_app|
      [ owning_app.underscore.humanize, owning_app ]
    }
    options = [["All", ""]] + owning_apps_with_labels

    options_for_select(options, selected_value || "")
  end
end
