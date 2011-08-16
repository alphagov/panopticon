## Panopticon

Panopticon is the app that looks out across the infrastructure, keeping a full record 
of URLs.

Its initial use case is providing a simple service that can be used to reserve a 'slug'
so that we have unique URLs.

### Slug Service

`POST /slugs
slug[name]=my-slug&slug[owning_app]=my_app`

Expected responses are:

* 201 Created : The slug was available and ownership of it has been recorded
* 406 Not Acceptable : The slug was already taken

`GET /slugs/{slug}`

Expected responses are:

* 200 OK : Slug exists. Returns JSON encoded details, eg. {"slug":"my-slug","owning_app":"guides","kind":"guide","active":true}
* 404 Not Found: Slug does not exist

Note that you should check the 'active' value of a returned slug to see if it's currently in use. Inactive slugs will not be routed.

