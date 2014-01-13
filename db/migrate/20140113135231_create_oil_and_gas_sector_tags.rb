class CreateOilAndGasSectorTags < Mongoid::Migration
  def self.oil_and_gas_topics
    [
      { slug: "carbon-capture-and-storage", title: "Carbon capture and storage" },
      { slug: "environment-reporting-and-regulation", title: "Environment reporting and regulation" },
      { slug: "exploration-and-development", title: "Exploration and development" },
      { slug: "fields-and-wells", title: "Fields and wells" },
      { slug: "finance-and-taxation", title: "Finance and taxation" },
      { slug: "infrastructure-and-decommissioning", title: "Infrastructure and decommissioning" },
      { slug: "licensing", title: "Licensing" },
      { slug: "onshore-oil-and-gas", title: "Onshore oil and gas" }
    ]
  end

  def self.up
    Tag.create!(tag_type: "industry_sector", tag_id: "oil-and-gas", title: "Oil and gas")

    oil_and_gas_topics.each do |topic|
      Tag.create!(tag_type: "industry_sector", parent_id: "oil-and-gas", tag_id: "oil-and-gas/#{topic[:slug]}", title: topic[:title])
    end
  end

  def self.down
    Tag.by_tag_id("oil-and-gas", "industry_sector").destroy

    oil_and_gas_topics.each do |topic|
      Tag.by_tag_id("oil-and-gas/#{topic[:slug]}", "industry_sector").destroy
    end
  end
end
