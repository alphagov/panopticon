class CorrectPublishingApp < Mongoid::Migration
  def self.up
    Artefact.where(owning_app: 'publisher', kind: 'smart-answer').update_all(owning_app: 'smartanswers')
    Artefact.where(owning_app: 'publisher', kind: 'travel-advice').update_all(owning_app: 'travel-advice-publisher')
  end

  def self.down
  end
end
