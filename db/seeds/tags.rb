def create_or_update_tag(options)
  tag_id = options.delete(:tag_id)
  tag = Tag.where(:tag_id => tag_id).first || Tag.new(:tag_id => tag_id)
  tag.update_attributes(options)
end

def delete_tags(tag_ids)
  tag_ids.each do |tag_id|
    tag = Tag.where(:tag_id => tag_id).first
    tag.delete if tag
  end
end

def add_team_tag(name, id, description)
  create_or_update_tag(
      title: name,
      tag_type: "team",
      tag_id: id,
      description: description)
end

delete_tags(['global',
            'london',
            'learning',
            'people',
            'people/tech-team',
            'people/commercial-team',
            'people/executive-team',
            'people/board',
            'people/operations-team',
            'people/staff',
            'people/trainers',
            'people/members',
            'people/start-ups',
            'people/writers',
            'people/artists',
            'news',
            'executive',
            'commercial',
            'operation'])

create_or_update_tag(
    title: "Featured item?",
    tag_type: "featured",
    tag_id: "featured",
    description: "Featured item?")

create_or_update_tag(
    title: "DaPaaS Partner",
    tag_type: "person",
    tag_id: "partner-biography",
    description: "DaPaaS Partner")

create_or_update_tag(
    title: "Team member",
    tag_type: "person",
    tag_id: "team",
    description: "Team member")

create_or_update_tag(
    title: "Trainer",
    tag_type: "person",
    tag_id: "trainers",
    description: "Trainer")

create_or_update_tag(
    title: "Member",
    tag_type: "person",
    tag_id: "members",
    description: "Member")

create_or_update_tag(
    title: "Start Ups",
    tag_type: "person",
    tag_id: "start-ups",
    description: "Start-up member")

create_or_update_tag(
    title: "Writer",
    tag_type: "person",
    tag_id: "writers",
    description: "Writer")

create_or_update_tag(
    title: "Artist",
    tag_type: "person",
    tag_id: "artists",
    description: "Artists")

# Programmes
# Core
add_team_tag("Culture", "culture-programme", "Culture Programme")
add_team_tag("Environment", "environment-programme", "Environment Programme")
add_team_tag("Strategy", "strategy-programme", "Strategy Programme")
# Global Network
add_team_tag("Franchise", "franchise-programme", "Franchise Programme")
add_team_tag("Learning", "learning-programme", "Learning Programme")
add_team_tag("Membership", "membership-programme", "Membership Programme")
# Innovation
add_team_tag("Evidence", "evidence-programme", "Evidence Programme")
add_team_tag("R&D", "rnd-programme", "R&D Programme")
add_team_tag("Services", "services-programme", "Services Programme")

# Functional Teams
add_team_tag("Leadership", "leadership-team", "Leadership Team")
add_team_tag("Finance", "finance-team", "Finance Team")
add_team_tag("Sales", "sales-team", "Sales Team")
add_team_tag("Marketing", "marketing-team", "Marketing Team")
add_team_tag("Engagement", "engagement-team", "Engagement Team")
add_team_tag("Account Management", "account-mgmt-team", "Account Management Team")
add_team_tag("Project Management", "project-mgmt-team", "Project Management Team")
add_team_tag("Consultancy", "consultancy-team", "Consultancy Team")
add_team_tag("Research", "research-team", "Research Team")
add_team_tag("Training", "training-team", "Training Team")
add_team_tag("Product Management", "product-mgmt-team", "Product Management Team")
add_team_tag("Software", "software-team", "Software Team")
add_team_tag("Communications", "communications-team", "Communications Team")
add_team_tag("Production", "production-team", "Production Team")
add_team_tag("Events", "events-team", "Events Team")
add_team_tag("Business Support", "business-support-team", "Business Support Team")
add_team_tag("People Dev", "people-dev-team", "People Dev Team")

# Other
add_team_tag("Board", "team-board", "Board Member")
add_team_tag("Intern", "team-intern", "Intern")
add_team_tag("Associate", "team-associate", "Associate")

create_or_update_tag(
    title: "Consultation Response",
    tag_type: "timed_item",
    tag_id: "consultation-response",
    description: "Consultation Response")

create_or_update_tag(
    title: "Procurement Item",
    tag_type: "timed_item",
    tag_id: "procurement",
    description: "Procurement Item")

create_or_update_tag(
    title: "News Item",
    tag_type: "article",
    tag_id: "news",
    description: "News Item")

create_or_update_tag(
    title: "Blog Post",
    tag_type: "article",
    tag_id: "blog",
    description: "Blog Post")

create_or_update_tag(
    title: "Media Release",
    tag_type: "article",
    tag_id: "media",
    description: "Media Release")

create_or_update_tag(
    title: "Start Up",
    tag_type: "organization",
    tag_id: "start-up",
    description: "Start Up")

create_or_update_tag(
    title: "Partner",
    tag_type: "organization",
    tag_id: "partner",
    description: "Partner")

create_or_update_tag(
    title: "Member",
    tag_type: "organization",
    tag_id: "member",
    description: "Member")

create_or_update_tag(
    title: "Lunchtime Lecture",
    tag_type: "event",
    tag_id: "lunchtime-lecture",
    description: "Lunchtime Lecture")

create_or_update_tag(
    title: "Meetup",
    tag_type: "event",
    tag_id: "meetup",
    description: "Meetup")

  create_or_update_tag(
    title: "Research Afternoon",
    tag_type: "event",
    tag_id: "research-afternoon",
    description: "Research Afternoon")

create_or_update_tag(
    title: "Open Data Challenge Series",
    tag_type: "event",
    tag_id: "open-data-challenge-series",
    description: "Open Data Challenge Series")

create_or_update_tag(
    title: "Roundtable",
    tag_type: "event",
    tag_id: "roundtable",
    description: "Roundtable")

create_or_update_tag(
    title: "Workshops",
    tag_type: "event",
    tag_id: "workshop",
    description: "Workshop")

create_or_update_tag(
    title: "Networking Event",
    tag_type: "event",
    tag_id: "networking-events",
    description: "Networking Event")

create_or_update_tag(
    title: "Panel Discussion",
    tag_type: "event",
    tag_id: "panel-discussions",
    description: "Panel Discussion")

create_or_update_tag(
    title: "DaPaaS",
    tag_type: "role",
    tag_id: "dapaas",
    description: "DaPaaS")

create_or_update_tag(
    title: "ODI",
    tag_type: "role",
    tag_id: "odi",
    description: "ODI")
