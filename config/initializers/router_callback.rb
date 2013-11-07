# In development environments we don't want to depend on Router unless
# explicitly told to do so
if Rails.env.development?
  update_router = ENV['UPDATE_ROUTER'].present?
else
  update_router = true
end

if update_router
  Rails.logger.info "Registering router observer for artefacts"
  # Use to_prepare so this gets reloaded with the app when in development
  # In production, it will only be called once
  ActionDispatch::Callbacks.to_prepare do
    Panopticon::Application.config.mongoid.observers << :update_router_observer
  end
else
  Rails.logger.info "In development/test mode: not registering router observer"
end
