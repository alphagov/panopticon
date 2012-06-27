# In development environments we don't want to depend on Rummager unless
# explicitly told to do so
unless Rails.env.development?
  update_search = true
else
  update_search = ENV['UPDATE_SEARCH'].present?
end

if update_search
  Rails.logger.info "Registering search observer for artefacts"
  Panopticon::Application.config.mongoid.observers << :update_search_observer
else
  Rails.logger.info "In development/test mode: not registering search observer"
end
