IMPORTING_LEGACY_DATA = true # See also artefact.rb

unless defined? Rails
  $stderr.puts "Run me with script/rails r #$0 < export.json"
  exit 1
end

def build_params(hash, keys)
  Hash[keys.map { |k| [k, hash[k.to_s]] }]
end

export = JSON.parse($stdin.read)

artefact_id_map = {}
contact_id_map = {}

export["users"].each do |u|
  params = build_params(u, [:name, :uid, :version, :email])
  User.create!(params)
end

export["artefacts"].each do |a|
  next unless a["contact"]
  params = build_params(a["contact"], [
    :contactotron_id, :email_address, :name, :opening_hours, :postal_address,
    :website_url
  ])
  if a["contact"]["phone_numbers"]
    params["phone_numbers"] = a["contact"]["phone_numbers"].map { |pn|
      { kind: pn["kind"], label: pn["label"], value: pn["value"] }
    }
  end
  contact = Contact.create!(params)
  contact_id_map[a["contact"]["id"]] = contact._id
end

export["artefacts"].each do |a|
  params = build_params(a, [
    :section, :name, :slug, :kind, :owning_app, :active, :tags,
    :need_id, :department, :fact_checkers, :relatedness_done,
    :publication_id, :business_proposition
  ])
  artefact = Artefact.new(params)
  if a["contact"]
    artefact.contact = Contact.find(contact_id_map[a["contact"]["id"]])
  end
  artefact.save!
  artefact_id_map[a["id"]] = artefact._id
end

export["artefacts"].each do |a|
  artefact = Artefact.find(artefact_id_map[a["id"]])
  a["related_items"].each do |r|
    related = Artefact.find(artefact_id_map[r["artefact"]["id"]])
    artefact.related_artefacts << related
  end
end
