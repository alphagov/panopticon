class SearchIndex

  class << self
    extend Memoist

    def instance(role = 'dapaas')
      Rummageable::Index.new(rummager_host, role, logger: Rails.logger)
    end
    memoize :instance

    def rummager_host
      ENV["RUMMAGER_HOST"] || Plek.current.find('search')
    end
  end

end
