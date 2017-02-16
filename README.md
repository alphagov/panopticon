# Panopticon

**This application has been [retired](https://docs.publishing.service.gov.uk/apps/panopticon.html).**

Panopticon is an application originally built to act as a central repository for content on GOV.UK.

![Screenshot of Panopticon, April 2016](docs/screenshot.png)

## Live examples

- [panopticon.publishing.service.gov.uk](https://panopticon.publishing.service.gov.uk)

## Nomenclature

- **Artefact**: a document on GOV.UK.

## Technical documentation

Panopticon provides three interfaces:

- An admin UI where items can be created and their metadata edited
- A writeable API where applications can register the content they provide

Panopticon shares a database with [Mainstream Publisher](https://github.com/alphagov/publisher), [Content API](https://github.com/alphagov/govuk_content_api) and [Travel Advice Publisher](https://github.com/alphagov/travel-advice-publisher). They share application code via the [govuk_content_models](https://github.com/alphagov/govuk_content_models) gem.

### Dependencies

- [publishing-api](https://github.com/alphagov/publishing-api) for registering URLs.
- [router-api](https://github.com/alphagov/router-api) also for registering URLs.

### Running the application

In the development VM:

```
cd /var/govuk/development && bowl panopticon
```

The app with appear at http://panopticon.dev.gov.uk/.

### Running the test suite

`bundle exec rake`

## Licence

[MIT License](LICENCE)
