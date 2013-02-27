module ApplicationHelper
  # Set class on active navigation items
  def nav_link(text, link)
    determinant_params = ["owning_app"]
    link_query = Rack::Utils.parse_nested_query(URI.parse(link).query)
    query_matches = determinant_params.all? { |p| params[p] == link_query[p] }

    recognized = Rails.application.routes.recognize_path(link)
    controller_matches = recognized[:controller] == params[:controller]
    action_matches = recognized[:action] == params[:action]

    if (controller_matches && action_matches && query_matches)
      content_tag(:li, :class => "active") do
        link_to( text, link)
      end
    else
      content_tag(:li) do
        link_to( text, link)
      end
    end
  end
end
