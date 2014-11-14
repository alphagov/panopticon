desc "Change an organisation slug (DANGER!).\n

This rake task changes an organisation slug in panopticon.

It performs the following steps:
- changes the organisation slug
- changes associated artefacts to use the new slug (org slug is used as
  foreign key)
- reindexes the updated artefacts in search

It is one part of an inter-related set of steps which must be carefully
coordinated.

For reference:

https://github.com/alphagov/wiki/wiki/Changing-GOV.UK-URLs#changing-an-organisations-slug"

task :change_organisation_slug, [:old_slug, :new_slug] => :environment do |_task, args|
  logger = Logger.new(STDOUT)
  if args[:old_slug].present? && args[:new_slug].present?
    ::OrganisationSlugChanger.new(
      args[:old_slug],
      args[:new_slug],
      logger: logger,
    ).call
  else
    logger.error("Please specifiy [old_slug,new_slug] arguments")
    exit(1)
  end
end
