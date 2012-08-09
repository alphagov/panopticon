def create_section
  TagRepository.put(
    tag_id: "crime",
    tag_type: "section",
    title: "Crime"
  )
  return TagRepository.load "crime"
end

def create_sections
  create_section
  TagRepository.put(
    tag_id: "crime/batman",
    tag_type: "section",
    title: "Batman"
  )
  return ["crime", "crime/batman"].map { |tag_id| TagRepository.load tag_id }
end

def select_section(section)
  select section.title, :from => "artefact[sections][]"
end

def unselect_section(section)
  select section.title, :from => "artefact[sections][]"
end

def add_section(artefact, section)
  # Ugh, inconsistent section getting and setting
  artefact.sections = (artefact.sections + [section]).map(&:tag_id)
  artefact.save!
end
