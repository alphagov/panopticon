class MarkUnpublishedMmoSlugsAsArchivedV2 < Mongoid::Migration
  # Marine Management Organisation
  # Sourced from https://gist.github.com/JordanHatch/a389a32abf0eaca89fec
  # which was sourced from https://gist.github.com/elliotcm/1a6f9159448d66dc97bb
  UNPUBLISHED_SLUGS = [
    "apply-for-a-european-fisheries-fund-grant",
    "applying-for-a-fishing-vessel-licence",
    "buy-and-sell-first-sale-marine-fish",
    "changes-to-your-fishing-vessel-licence",
    "closed-fishing-areas",
    "disposal-of-dredged-material-at-sea-regulations-and-controls",
    "east-marine-plan-areas",
    "electronic-recording-and-reporting-of-fishing-activity",
    "european-fisheries-fund-fishing-industry-common-interests",
    "european-fisheries-fund-organic-and-environmentally-friendly-measures-grant",
    "european-fisheries-fund-processing-and-marketing-fisheries-and-aquaculture",
    "european-fisheries-fund-projects",
    "fisheries-catch-limits",
    "fisheries-catch-limits-10-metres-and-under",
    "fisheries-catch-limits-non-sector",
    "fishing-industry-regulations",
    "fishing-vessels-licence-upgrades-after-re-engining",
    "gaining-consent-to-dredge-marine-minerals",
    "get-a-fishing-vessel-licence-mussel-seed",
    "get-an-oil-spill-treatment-product-approved",
    "get-involved-in-marine-planning",
    "government/collections/fishing-vessel-licences-10-metre-and-under-vessels",
    "government/collections/fishing-vessel-licences-over-10-metre-vessels",
    "government/collections/marine-conservation-byelaws",
    "government/publications/approved-electronic-logbook-software-systems",
    "government/publications/category-a-annexes",
    "government/publications/category-a-conditions-and-schedule",
    "government/publications/category-a-islands",
    "government/publications/category-a-pelagic-annexes",
    "government/publications/category-a-pelagic-conditions-and-schedule",
    "government/publications/category-b-annexes",
    "government/publications/category-b-conditions-and-schedule",
    "government/publications/category-c-annexes",
    "government/publications/category-c-conditions-and-schedule",
    "government/publications/deep-sea-species-annexes",
    "government/publications/deep-sea-species-conditions-and-schedule",
    "government/publications/east-inshore-and-east-offshore-marine-plans",
    "government/publications/handline-mackerel-conditions-and-schedule",
    "government/publications/non-sector-capped-licences",
    "government/publications/non-sector-uncapped-licences",
    "government/publications/sector-annexes",
    "government/publications/sector-conditions-and-schedule",
    "government/publications/thames-and-blackwater-conditions-and-schedule",
    "harbour-development-and-the-law",
    "how-a-marine-plan-is-made",
    "how-to-clean-an-oil-spill-at-sea",
    "investing-in-aquaculture",
    "investing-on-board-your-fishing-vessel",
    "lease-extra-fishing-quota",
    "licences-for-offshore-renewable-energy-installations",
    "make-a-european-fisheries-fund-claim",
    "make-changes-to-your-fishing-vessel-licence",
    "make-changes-to-your-fishing-vessel-licence-combine-and-separate-licences",
    "manage-fisheries-quota",
    "manage-your-fishing-effort-cod-recovery-zone",
    "manage-your-fishing-effort-sole-recovery-zone",
    "manage-your-fishing-effort-western-waters-scallops",
    "marine-construction-and-coastal-protection",
    "marine-licensing-additional-information-for-dredging-applications",
    "marine-licensing-aggregate-extraction",
    "marine-licensing-assess-the-impact-on-the-environment",
    "marine-licensing-disposing-waste-at-sea",
    "marine-licensing-diving",
    "marine-licensing-dredging",
    "marine-licensing-emergency-application",
    "marine-licensing-exemptions",
    "marine-licensing-fast-track-application-process",
    "marine-licensing-local-or-regional-dredging-conditions",
    "marine-licensing-maintenance-activities",
    "marine-licensing-marker-buoys-and-posts",
    "marine-licensing-minor-removals",
    "marine-licensing-sampling-and-sediment-analysis",
    "marine-licensing-scaffolding-and-ladders",
    "marine-licensing-scientific-sampling",
    "marine-wildlife-licence",
    "offshore-cables-and-pipelines",
    "penalties-for-fishing-offences",
    "record-and-report-your-fishing-activity",
    "record-sales-and-submit-sales-notes",
    "report-a-wildlife-incident",
    "report-and-respond-to-a-marine-pollution-incident",
    "south-marine-plan-areas",
    "the-days-at-sea-scheme",
    "the-days-at-sea-scheme-sole-recovery-zone",
    "trace-fish-products",
    "transport-fish",
    "understand-your-fishing-vessel-licence",
    "weigh-fish-products"
  ].freeze

  def self.up
    Artefact.where(:slug.in => UNPUBLISHED_SLUGS).each do |artefact|
      puts "Archiving artefact #{artefact.slug}"
      artefact.update_attribute(:state, 'archived')
    end
  end

  def self.down
    Artefact.where(:slug.in => UNPUBLISHED_SLUGS).each do |artefact|
      puts "Setting artefact #{artefact.slug} to live"
      artefact.update_attribute(:state, 'live')
    end
  end
end
