unless defined? Rails
  $stderr.puts "Run me with script/rails r #$0"
  exit 1
end

output = {
  "users" => User.all.map(&:as_json),
  "artefacts" => Artefact.all.map(&:as_json)
}

puts JSON.dump(output)
