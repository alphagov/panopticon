class RemoveAllNonMaslowNeedIds < Mongoid::Migration
  def self.up
    artefacts_with_needs = Artefact.where(:need_ids.nin => [[], nil])
    maslow_need = lambda { |need_id| need_id =~ /^\d{6}$/ }
    artefacts_with_non_maslow_needs = artefacts_with_needs.reject {|a| a.need_ids.all?(&maslow_need) }

    artefacts_with_non_maslow_needs.each do |artefact|
      old_need_ids = artefact.need_ids
      new_need_ids = artefact.need_ids.select(&maslow_need)
      artefact.need_ids = new_need_ids
      artefact.save!
      puts "Updated need_ids for artefact #{artefact.id.to_s}: #{old_need_ids.inspect} => #{new_need_ids}"
    end
  end

  def self.down
  end
end
