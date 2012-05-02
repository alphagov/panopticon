unless defined? Rails
  $stderr.puts "Run me with script/rails r #$0 < export.json"
  exit 1
end

export = JSON.parse($stdin.read)

old_to_new = {}

export["artefacts"].each do |a|
  slug = a["slug"]
  old_id = a["id"]
  artefact = Artefact.where(slug: slug).first
  if artefact
    old_to_new[old_id] = artefact._id.to_s
  else
    $stderr.puts "Could not find #{slug}"
  end
end

puts JSON.dump(old_to_new)
