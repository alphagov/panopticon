require 'gds_api/json_client'

class GdsApi::PanopticonApi < GdsApi::Base
  def register(details)
    put_json(base_url + ".json", artefact: details)
  end

  private
  def adapter_name
    "panopticon"
  end

  def base_url
    "#{endpoint}/artefacts"
  end
end

# namespace :core_api do
#   desc "Register application metadata with panopticon"
#   task :register => :environment do
#     flow_registry = SmartAnswer::FlowRegistry.new
#     flow = flow_registry.flows.first
#     presenter = TextPresenter.new(flow)

#     interface = GdsApi::PanopticonApi.new
#     interface.register({
#       need_id: flow.need_id,
#       slug: flow.name,
#       title: presenter.title,
#       description: presenter.description,
#       format: "smart_answer",
#       section: presenter.section_slug,
#       subsection: presenter.subsection_slug,
#       link: "/#{flow.name}",
#       indexable_content: presenter.text,
#       owning_app: 'smart-answers'
#     })
#   end
# end
