class AddNewTags < Mongoid::Migration
  def self.up
    require File.join(Rails.root, 'db','seeds','tags.rb')
  end

  def self.down
  end
end