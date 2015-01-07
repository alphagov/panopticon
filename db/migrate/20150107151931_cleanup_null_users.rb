class CleanupNullUsers < Mongoid::Migration
  def self.up
    User.where(:uid => nil).destroy_all
  end

  def self.down
  end
end
