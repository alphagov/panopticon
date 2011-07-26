## Panopticon

Panopticon is the app that looks out across the infrastructure, keeping a full record 
of URLs.

Its initial use case is providing a simple service that can be used to reserve a 'slug'
so that we have unique URLs.

### Slug Service

eg.

POST /slugs
slug[name]=my-slug&slug[owning_app]=my_app

Expected responses are:

201 Created : The slug was available and ownership of it has been recorded
406 Not Acceptable : The slug was already taken