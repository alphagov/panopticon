if ENV['QUIRKAFLEEG_AIRBRAKE_KEY']
2	  Airbrake.configure do |config|
3	    config.api_key = ENV['QUIRKAFLEEG_AIRBRAKE_KEY']
4	  end
5	end
