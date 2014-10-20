class RegisterPrefixRoutesForSectors < Mongoid::Migration
  def self.up
    sectors = Artefact.where(kind: 'specialist_sector').to_a
    sectors.each do |sector_artefact|
      next unless sector_artefact.slug.include?('/') # Child tags only

      update_routes(sector_artefact, prefixes: sector_artefact.paths, paths: [])
    end
  end

  def self.down
    sectors = Artefact.where(kind: 'specialist_sector').to_a
    sectors.each do |sector_artefact|
      next unless sector_artefact.slug.include?('/') # Child tags only

      update_routes(sector_artefact, prefixes: [], paths: sector_artefact.prefixes)
    end
  end

  def self.update_routes(artefact, options = {})
    prefixes = options.fetch(:prefixes).dup
    paths = options.fetch(:paths).dup

    puts "Updating #{artefact.slug}"
    puts "-- Setting paths to #{paths}"
    puts "-- Setting prefixes to #{prefixes}"

    routeable_artefact = RoutableArtefact.new(artefact)
    routeable_artefact.delete(skip_commit: true)

    artefact.update_attributes!(prefixes: prefixes, paths: paths)
    artefact.reload

    routeable_artefact = RoutableArtefact.new(artefact)
    routeable_artefact.submit
  end
end
