namespace :messenger do
  desc "Listen for publication deleted messages so that the publication can be removed from panopticon"
  task :listen => :environment do
    Daemonette.run("panopticon_deleted_publication_listener") do
      require "deleted_publication_listener.rb"
      DeletedPublicationListener.new.listen
    end
  end
end
