Airbrake.configure do |config|
  config.api_key = ENV['ERRBIT_API_KEY']
  config.host = "errbit.#{ENV['GOVUK_APP_DOMAIN']}"
  config.secure = true
  config.environment_name = ENV['ERRBIT_ENVIRONMENT_NAME']
end
