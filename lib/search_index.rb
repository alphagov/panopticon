class SearchIndex
  def self.instance
    @@instance ||= Rummageable::Index.new(rummager_host, '/dapaas', logger: Rails.logger)
  end

  def self.rummager_host
    ENV["RUMMAGER_HOST"] || Plek.current.find('search')
  end
end
