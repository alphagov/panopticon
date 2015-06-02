#on hold as this does not necessarily work for world organisations

#require 'lib/organisation_slug_changer'

#class RemoveManualChangeHistories < Mongoid::Migration
  #OLD_SLUG = 'british-trade-cultural-office-taiwan'
  #NEW_SLUG = 'british-office-taipei'

  #def self.up
    #OrganisationSlugChanger.new(OLD_SLUG, NEW_SLUG).call
  #end

  #def self.down
    #self.update_org_tag(NEW_SLUG, OLD_SLUG)
    #OrganisationSlugChanger.new(NEW_SLUG, OLD_SLUG).call
  #end
#end
