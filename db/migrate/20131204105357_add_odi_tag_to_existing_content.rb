class AddOdiTagToExistingContent < Mongoid::Migration
  def self.up
    Artefact.all.each { |a| a.update_attributes!(:roles => ['odi']) rescue nil }
  end

  def self.down
  end
end