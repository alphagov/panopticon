module CsvFileHelper
  def csv_path_for_data(name)
    File.expand_path('../../support/data/' + name.parameterize + '.csv', __FILE__)
  end
end

World(CsvFileHelper)