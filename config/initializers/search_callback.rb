# In development environments we don't want to depend on Rummager unless
# explicitly told to do so
unless Rails.env.development?
  update_search = ENV['QUIRKAFLEEG_SEARCH_DISABLE'].nil?
else
  update_search = ENV['UPDATE_SEARCH'].present?
end

if update_search
  Rails.logger.info "Registering search observer for artefacts"
  # Use to_prepare so this gets reloaded with the app when in development
  # In production, it will only be called once
  ActionDispatch::Callbacks.to_prepare do
    Panopticon::Application.config.mongoid.observers << :update_search_observer
  end
else
  Rails.logger.info "In development/test mode: not registering search observer"
end
