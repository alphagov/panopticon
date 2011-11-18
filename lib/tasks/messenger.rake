namespace :messenger do
  desc 'Listen for messages so that panopticon can remain up to date'
  task :listen do
    Daemonette.run("panopticon_deleted_publication_listener") do
      require "deleted_publication_listener.rb"
      Rake::Task["environment"].invoke
      DeletedPublicationListener.new.listen
    end

    Daemonette.run('panopticon_contact_listener') do
      require 'contact_listener.rb'
      Rake::Task['environment'].invoke
      ContactListener.new.listen
    end
                                  
    Daemonette.run('panopticon_need_listener') do
      require 'need_listener.rb'  
      Rake::Task['environment'].invoke
      NeedListener.new.listen                         
    end
  end            
end
