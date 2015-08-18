#! /usr/bin/env ruby

unless defined? Rails
  $stderr.puts "Run me with script/rails r #$0"
  exit 1
end

require "gds_api/router"

router_api = GdsApi::Router.new(Plek.find("router-api"))

scope = Artefact.where(kind: "detailed_guide")
count = scope.count
scope.to_a.each_with_index do |guide, i|
  puts "Processing #{guide.slug} (#{i + 1}/#{count})"
  guide.slug.sub!(%r{^(guidance/)?(deleted-)?}, 'guidance/')

  # Check the root route is owned by Whitehall
  route = router_api.get_route("/#{guide.slug.sub(%r{^guidance/}, '')}")
  if route && route["handler"] == "backend" && route["backend_id"] == "whitehall-frontend"
    guide.paths = guide.paths.map { |pa| pa.sub(%r{^/(guidance/)?(deleted-)?}, '/guidance/') }.uniq
    puts "Paths set to #{guide.paths.inspect}"
  else
    puts "Skipping, not owned by whitehall"
  end

  guide.save
end
