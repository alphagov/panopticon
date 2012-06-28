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
  params = build_params(u, [
    :name, :uid, :version, :email, :created_at, :updated_at
  ])
  FactoryGirl.create(:user, params)
end

export["artefacts"].each do |a|
  # Don't create contacts for artefacts that already exist
  next if Artefact.where(slug: a["slug"]).any?

  next unless a["contact"]

  params = build_params(a["contact"], [
    :contactotron_id, :email_address, :name, :opening_hours, :postal_address,
    :website_url, :created_at, :updated_at
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
  # Don't duplicate existing artefacts
  if Artefact.where(slug: a["slug"]).any?
    puts "exists: #{a["slug"]}"
    next
  end

  params = build_params(a, [
    :section, :name, :slug, :kind, :owning_app, :active, :tags,
    :need_id, :department, :fact_checkers, :relatedness_done,
    :publication_id, :business_proposition, :created_at, :updated_at
  ])
  artefact = Artefact.new(params)
  if a["contact"]
    artefact.contact = Contact.find(contact_id_map[a["contact"]["id"]])
  end
  artefact.save!
  artefact_id_map[a["id"]] = artefact._id
  puts "add: #{a["slug"]}; #{a["id"]} => #{artefact._id}"
end

export["artefacts"].each do |a|
  # Skip anything we haven't created in this run
  next unless artefact_id_map[a["id"]]

  artefact = Artefact.find(artefact_id_map[a["id"]])
  a["related_items"].each do |r|
    related = Artefact.where(slug: artefact_id_map[r["artefact"]["slug"]]).first
    if related
      artefact.related_artefacts << related
      puts "relate: #{artefact.slug} => #{related.slug}"
    end
  end
end
