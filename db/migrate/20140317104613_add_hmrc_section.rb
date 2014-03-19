class AddHmrcSection < Mongoid::Migration
  TAG_ID = 'tax/dealing-with-hmrc'

  def self.up
    tag = Tag.create!(
      tag_id: TAG_ID,
      title: 'Dealing with HMRC',
      tag_type: 'section',
      parent_id: 'tax',
      description: 'Reporting changes, agents, appeals, checks, complaints and help with tax'
    )

    content.each do |artefact|
      a = Artefact.find_by_slug(artefact[:slug])
      if a
        if artefact[:cat] == 'primary'
          a.tags.unshift(tag)
        else
          a.tags << tag
        end
        a.save!
      end
    end
  end

  def self.down
    Tag.by_tag_id(TAG_ID, 'section').destroy
  end

  private

  def self.content
    [
      { slug: 'tax-tribunal', cat: 'secondary' },
      { slug: 'self-assessment-appeals', cat: 'secondary' },
      { slug: 'tax-appeals', cat: 'primary' },
      { slug: 'difficulties-paying-hmrc', cat: 'primary' },
      { slug: 'if-you-dont-pay-your-tax-bill', cat: 'primary' },
      { slug: 'tell-hmrc-about-a-change-of-name-or-address', cat: 'primary' },
      { slug: 'tell-hmrc-changed-business-details', cat: 'primary' },
      { slug: 'handling-someones-tax-on-their-behalf', cat: 'primary' },
      { slug: 'appoint-tax-agent', cat: 'primary' },
      { slug: 'self-assessment-tax-return-checks', cat: 'secondary' },
      { slug: 'vat-visits-inspections', cat: 'secondary' },
      { slug: 'tax-help', cat: 'primary' },
      { slug: 'tax-compliance-checks', cat: 'primary' },
      { slug: 'hmrc-staff-complaints', cat: 'primary' }
    ]
  end
end
