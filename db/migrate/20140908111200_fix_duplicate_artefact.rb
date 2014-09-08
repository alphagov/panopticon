class FixDuplicateArtefact < Mongoid::Migration
  DUPLICATE_ARTEFACT_ID = "53189b90ed915d2086000303"
  CORRECT_ARTEFACT_ID = "53539f88e5274a30c1006946"

  def self.up
    duplicate_artefact = Artefact.where(:_id => DUPLICATE_ARTEFACT_ID).first
    correct_artefact = Artefact.where(:_id => CORRECT_ARTEFACT_ID).first

    if duplicate_artefact.present? && correct_artefact.present?

      # Remap any related artefacts
      Artefact.where(:related_artefact_ids => DUPLICATE_ARTEFACT_ID).each do |artefact|
        # use map to preserve the order
        original_related_ids = artefact.related_artefact_ids.map(&:to_s)
        new_related_ids = original_related_ids.map {|id| id == DUPLICATE_ARTEFACT_ID ? CORRECT_ARTEFACT_ID : id }
        puts "Updating related artefacts for #{artefact.slug} (#{original_related_ids} => #{new_related_ids})"
        artefact.set(:related_artefact_ids, new_related_ids)
      end

      puts "Deleting duplicate artefact"
      duplicate_artefact.destroy
    end
  end

  def self.down
  end
end
