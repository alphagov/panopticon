namespace :migrate do

  desc "Copy all users into app-specific user collections"
  task :duplicate_users_for_panopticon_and_publisher => :environment do
    require 'user'
    # Not really required, but a guard against running with the newer User model
    class User
      self.collection_name = "users"
    end

    class PanopticonUser
      include Mongoid::Document
      include Mongoid::Timestamps

      field "name",                type: String
      field "uid",                 type: String
      field "version",             type: Integer
      field "email",               type: String
      field "permissions",         type: Hash
      field "remotely_signed_out", type: Boolean, default: false
    end

    class PublisherUser
      include Mongoid::Document
      include Mongoid::Timestamps

      field "name",                type: String
      field "uid",                 type: String
      field "version",             type: Integer
      field "email",               type: String
      field "permissions",         type: Hash
      field "remotely_signed_out", type: Boolean, default: false
    end

    User.all.each do |user|
      PanopticonUser.timeless.create!(user.attributes)
      PublisherUser.timeless.create!(user.attributes)
    end
  end

  desc "Sets the businesslink legacy source on all business proposition content"
  task :set_businesslink_tag_on_buisiness_artefacts => :environment do
    Artefact.observers.disable :update_search_observer, :update_router_observer do
      Artefact.where(:business_proposition => true).each do |artefact|
        unless artefact.legacy_source_ids.include?('businesslink')
          artefact.legacy_source_ids += %w(businesslink)
          artefact.save!
        end
      end
    end
  end
end
