class MarkUnpublishedMmoSlugsAsArchived < Mongoid::Migration
  # Marine Management Organisation
  # Sourced from https://gist.github.com/JordanHatch/a389a32abf0eaca89fec
  # which was sourced from https://gist.github.com/elliotcm/1a6f9159448d66dc97bb
  UNPUBLISHED_SLUGS = [
    "harbour-development-and-the-law",
    "disposal-of-dredged-material-at-sea-regulations-and-controls",
    "offshore-cables-and-pipelines",
    "marine-construction-and-coastal-protection",
    "licences-for-offshore-renewable-energy-installations",
    "european-fisheries-fund-fishing-industry-common-interests",
    "european-fisheries-fund-overview",
    "european-fisheries-fund-investing-in-aquaculture",
    "european-fisheries-fund-investing-on-board-your-fishing-vessel",
    "electronic-recording-and-reporting-of-fishing-activity",
    "financial-administrative-penalties-for-fishing-offences",
    "fishing-industry-regulations",
    "european-fisheries-fund-processing-and-marketing-fisheries-and-aquaculture-products",
    "applying-for-a-fishing-vessel-licence",
    "changes-to-your-fishing-vessel-licence",
    "fishing-vessels-licence-upgrades-after-re-engining",
    "the-days-at-sea-scheme-cod-recovery-zone",
    "the-days-at-sea-scheme-sole-recovery-zone",
    "clean-an-oil-spill-at-sea-and-get-oil-spill-treatments-approved",
    "report-and-respond-to-a-marine-pollution-incident",
    "get-an-oil-spill-treatment-product-approved",
    "government/collections/marine-conservation-byelaws",
    "european-fisheries-fund-organic-and-environmentally-friendly-measures",
    "gaining-consent-to-dredge-marine-minerals",
    "report-a-wildlife-incident",
    "understand-marine-wildlife-licences-and-report-an-incident",
    "government/publications/east-inshore-and-east-offshore-marine-plans",
    "marine-plans-development",
    "east-marine-plan-areas",
    "south-marine-plan-areas",
    "apply-for-a-european-fisheries-fund-grant",
    "make-a-european-fisheries-fund-claim",
    "manage-and-lease-fishing-quota",
    "fisheries-catch-limits-non-sector",
    "fisheries-catch-limits-10-metres-and-under",
    "understand-fisheries-catch-limits-and-closed-fishing-areas",
    "manage-fisheries-quota",
    "manage-your-fishing-effort-sole-recovery-zone",
    "manage-your-fishing-effort-western-waters-scallops",
    "get-involved-in-marine-planning",
    "get-a-fishing-vessel-licence-mussel-seed",
    "make-changes-to-your-fishing-vessel-licence",
    "make-changes-to-your-fishing-vessel-licence-combine-and-separate-licences",
    "understand-your-fishing-vessel-licence",
    "closed-fishing-areas",
    "record-and-report-your-fishing-activity-and-submit-sales-notes",
    "government/publications/approved-electronic-logbook-software-systems",
    "marine-licensing-emergency-application",
    "marine-licensing-fast-track-application-process",
    "marine-licensing-assess-the-impact-on-the-environment",
    "apply-to-take-samples-analyse-sediment-and-make-minor-removals",
    "buy-and-sell-first-sale-marine-fish",
    "record-sales-and-submit-sales-notes",
    "how-to-trace-weigh-and-distribute-fish-products",
    "weigh-fish-products",
    "transport-fish",
    "marine-licensing-scientific-sampling",
    "apply-to-construct-on-remove-from-and-dispose-to-the-seabed",
    "marine-licensing-diving",
    "apply-to-dredge-and-extract-aggregates",
    "marine-licensing-aggregate-extraction",
    "marine-licensing-local-or-regional-dredging-conditions",
    "marine-licensing-additional-information-for-dredging-applications",
    "marine-licensing-exemptions",
    "marine-licensing-maintenance-activities",
    "marine-licensing-marker-buoys-and-posts",
    "marine-licensing-minor-removals--2",
    "marine-licensing-scaffolding-and-ladders",
    "government/collections/fishing-vessel-licences-over-10-metre-vessels",
    "government/publications/category-a-conditions-and-schedule",
    "government/publications/category-a-annexes",
    "government/publications/category-a-islands",
    "government/publications/category-a-pelagic-conditions-and-schedule",
    "government/publications/category-a-pelagic-annexes",
    "government/publications/category-b-conditions-and-schedule",
    "government/publications/category-b-annexes",
    "government/publications/category-c-conditions-and-schedule",
    "government/publications/category-c-annexes",
    "government/publications/deep-sea-species-conditions-and-schedule",
    "government/publications/deep-sea-species-annexes",
    "government/publications/handline-mackerel-conditions-and-schedule",
    "government/publications/thames-and-blackwater-conditions-and-schedule",
    "government/collections/fishing-vessel-licences-10-metre-and-under-vessels",
    "government/publications/non-sector-uncapped-licences",
    "government/publications/sector-conditions-and-schedule",
    "government/publications/sector-annexes",
    "manage-your-fishing-effort-cod-recovery-zone",
    "government/publications/non-sector-capped-licences"
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
