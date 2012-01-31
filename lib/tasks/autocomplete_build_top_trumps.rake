namespace :autocomplete do
  desc 'Find all the titles and formats for the slugs in autocomplete-top-trumps.csv, writes out search-top-trumps.json'
  task :build_top_trumps => :environment do
    require 'csv'
    require 'json'

    input_file = "autocomplete-top-trumps.csv"
    output_file = "search-top-trumps.json"
    raise "Can't read #{input_file}" unless File.exist?(input_file)
    
    docs = []
    i = 0
    CSV.foreach(input_file) do |row|
      i +=1
      next if i == 1
      phrase, slug, weight = row
      slug = slug.gsub('/', '')
      a = Artefact.where(slug: slug).first
      if a
        docs << {
          "title" => a.name,
          "link" => "/" + a.slug,
          "format" => a.kind,
          "keywords" => phrase,
          "weight" => weight
        }
        
        docs << {
          "title" => a.name,
          "link" => "/" + a.slug,
          "format" => a.kind,
          "keywords" => a.name,
          "weight" => 0.5
        }
      else
        raise "Couldn't find slug '#{slug}'"
      end
    end

    File.open(output_file, "w")  do |f| 
      f << %q{if (typeof(GDS) == 'undefined') { GDS = {}; };} + "\n"
      f << %q{GDS.search_top_trumps = }
      f << JSON.dump(docs).gsub(/},{/, "},\n{")
      f << ";\n"
    end
  end
end

