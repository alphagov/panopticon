def create_section
  TagRepository.put :tag_id => 'crime', :tag_type => 'section', :title => 'Crime'
  return TagRepository.load 'crime'
end

def select_section(section)
  select section.title, :from => 'Sections'
end

def unselect_section(section)
  unselect section.title, :from => 'Sections'
end

def add_section(artefact, section)
  artefact.sections += [section.tag_id]
end
