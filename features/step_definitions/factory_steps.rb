Given /^there (?:is an?|are) (.*?)s? called ((?:"[^"]*"(?:, | and )?)+)$/ do |factory, names|
  names.scan(/"([^"]*)"/).flatten.each do |name|
    steps %Q{
      Given a #{factory} exists with a name of "#{name}"
    }
  end
end
