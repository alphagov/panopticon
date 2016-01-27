class ChildTagIdInput < FormtasticBootstrap::Inputs::StringInput
  def options
    if builder.object.parent_id.present?
      super.merge(prepend: "#{builder.object.parent_id}/")
    end
  end

  def to_html
    remove_parent_from_tag_id
    bootstrap_wrapping do
      builder.text_field(method, form_control_input_html_options)
    end
  end

protected

  def remove_parent_from_tag_id
    if builder.object.tag_id.present?
      builder.object.tag_id.sub!(/^#{builder.object.parent_id}\//, '')
    end
  end
end
