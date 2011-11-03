def split_names(names)
  names.scan(/"([^"]*)"/).flatten
end

def record_called(klass, name)
  klass.find_by_name! name
end

def records_called(klass, names)
  names.map { |name| record_called klass, name }
end
