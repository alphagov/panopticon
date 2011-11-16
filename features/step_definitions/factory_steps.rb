Given /^there (?:is an?|are) (.*?)s? called ((?:"[^"]*"(?:, | and )?)+)$/ do |factory, names|
  names.scan(/"([^"]*)"/).flatten.each do |name|
    Factory.create factory, :name => name
  end
end
