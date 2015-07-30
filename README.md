# Panopticon

The GOV.UK content platform has been built with a focus on tools over content.
That is manifest in the existence of numerous small applications that provide
focussed solutions to specific user needs, or offer a suite of similar but
distinct solutions; alongside the 'publisher/frontend' editorial tools there
are apps like 'smart answers', 'planners', and so on.

To bring that all together as a single site a single interface was required
to attach consistent metadata to the pieces, connect them together as 'related
items' and generally have a complete overview of all the solutions/artefacts in
the system. That's this app: Panopticon.

# Interfaces

Panopticon provides:

* an admin UI where items can be created and their metadata
  edited. This is authenticated in conjunction with sign-on-o-tron.
* a writeable API where applications can register the content
  they provide. This is authenticated using OAuth2.
* a read API for retrieving metadata about a given item

## Importing organisation tags

Panopticon includes a Rake task to create tags for each organisation from the
[Whitehall app](https://github.com/alphagov/whitehall). To run this in the
development environment, the production data source can be used, so that there
is no need to have an up-to-date Whitehall database.

    PLEK_SERVICE_WHITEHALL_ADMIN_URI=https://www.gov.uk/ bundle exec rake organisations:import

## Indexing artefacts in search

Panopticon includes observers which will index, update or delete records in the
search index when an artefact is updated. It expects an instance of
[Rummager](https://github.com/alphagov/rummager) to be present.
