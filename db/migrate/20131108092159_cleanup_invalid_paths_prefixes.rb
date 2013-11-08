class CleanupInvalidPathsPrefixes < Mongoid::Migration
  def self.up
    Artefact.skip_callback(:update, :after, :update_editions)
    Artefact.all.each do |a|
      all_paths = (a.prefixes || []) + (a.paths || [])
      if all_paths.any? {|p| ! a.send(:valid_url_path?, p) }
        puts "Invalid paths for #{a.slug} (#{a.state}, owning_app: #{a.owning_app})\n  prefixes: #{a.prefixes.inspect}\n  paths: #{a.paths.inspect}"
        a.paths = []
        a.prefixes = []
        a.save!
      end
    end
  end

  def self.down
  end
end
