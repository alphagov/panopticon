require "gds_api/router"

class RemoveInternationalDevelopmentFundTag < Mongoid::Migration
  def self.router_api
    @router_api ||= GdsApi::Router.new(Plek.current.find('router-api'))
  end

  def self.up
    Tag.by_tag_id("citizenship/international-development", "section").destroy
    router_api.add_redirect_route('/browse/citizenship/international-development', 'exact', '/international-development-funding')
    router_api.commit_routes
  end

  def self.down
    raise IrreversibleMigration
  end
end
