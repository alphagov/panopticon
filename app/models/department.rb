class Department
  # FIXME: This couples Panopticon operation to Imminence operation which I
  # don't like. Panopticon should probably denormalise this data every time
  # the data set is updated and just use that denormalised data here.
  def self.all
    data_set_url = Plek.current.find("data") + '/data_sets/public_bodies.json'
    data_set = JSON.parse open(data_set_url).read
    data_set.map { |department| department['id'] }.sort
  end
end
