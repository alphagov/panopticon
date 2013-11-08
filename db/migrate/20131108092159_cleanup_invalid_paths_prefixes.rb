class CleanupInvalidPathsPrefixes < Mongoid::Migration
  def self.up
    Artefact.skip_callback(:update, :after, :update_editions)
    Artefact.all.each do |a|
      all_paths = (a.prefixes || []) + (a.paths || [])
      if all_paths.any? {|p| ! valid_local_path?(p) }
        puts "Invalid paths for #{a.slug} (#{a.state}, owning_app: #{a.owning_app})\n  prefixes: #{a.prefixes.inspect}\n  paths: #{a.paths.inspect}"
        a.paths = []
        a.prefixes = []
        a.save!
      end
    end
  end

  def self.valid_local_path?(path)
    return false unless path.starts_with?("/")
    uri = URI.parse(path)
    uri.path == path && path !~ %r{//} && path !~ %r{./\z}
  rescue URI::InvalidURIError
    false
  end

  def self.down
  end
end
