if ENV['QUIRKAFLEEG_AIRBRAKE_KEY']
  Airbrake.configure do |config|
    config.api_key = ENV['QUIRKAFLEEG_AIRBRAKE_KEY']
  end
end
