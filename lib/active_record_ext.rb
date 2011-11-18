require 'marples/model_action_broadcast'

ActiveRecord::Base.class_eval do
  include Marples::ModelActionBroadcast
end

ActiveRecord::Base.marples_client_name = 'panopticon'
ActiveRecord::Base.marples_logger = Rails.logger
