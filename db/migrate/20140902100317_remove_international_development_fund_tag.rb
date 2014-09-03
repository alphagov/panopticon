class RemoveInternationalDevelopmentFundTag < Mongoid::Migration
  def self.up
    Tag.by_tag_id("citizenship/international-development", "section").destroy
  end

  def self.down
    raise IrreversibleMigration
  end
end
