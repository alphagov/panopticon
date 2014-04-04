class ChildTagIdInput < FormtasticBootstrap::Inputs::StringInput
  def to_html
    remove_parent_from_tag_id

    bootstrap_wrapping do
      parent_tag_html <<
      builder.text_field(method, input_html_options)
    end
  end

  protected

  def parent_tag_html
    if builder.object.parent_id.present?
      builder.template.content_tag :span, class: "parent-id" do
        "#{builder.object.parent_id}/"
      end
    end
  end

  def remove_parent_from_tag_id
    if builder.object.tag_id.present?
      builder.object.tag_id.sub!(/^#{builder.object.parent_id}\//, '')
    end
  end
end
