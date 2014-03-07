# ODI don't need the router just yet so let's straight up disable it unless
# we are running tests, they need the router observers to be active

if Rails.env.test?
  update_router = true
else
  update_router = ENV['QUIRKAFLEEG_ACTIVATE_AN_ROUTER'].present?
end

if update_router
  Rails.logger.info "Registering router observer for artefacts"
  # Use to_prepare so this gets reloaded with the app when in development
  # In production, it will only be called once
  ActionDispatch::Callbacks.to_prepare do
    Panopticon::Application.config.mongoid.observers << :update_router_observer
  end
else
  Rails.logger.info "Inactive mode: not registering router observer"
end
