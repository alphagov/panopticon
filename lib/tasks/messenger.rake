namespace :messenger do
  desc "Listen for publication deleted messages so that the publication can be removed from panopticon"
  task :listen do
    Daemonette.run("panopticon_deleted_publication_listener") do
      require "deleted_publication_listener.rb"
      Rake::Task["environment"].invoke
      DeletedPublicationListener.new.listen
    end
  end
end
