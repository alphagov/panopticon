#######
#
# This file will be run on every deploy, so make sure the changes here are non-destructive
#
#######

####### Primary Sections ########
[
  {:id=>"business",
  :title=>"Business",
  :description=>
   "Information about starting up and running a business in the UK, including help if you're self employed or a sole trader."},
 {:id=>"crime-and-justice",
  :title=>"Crime and justice",
  :description=>
   "Simple information to help answer your questions on jury service, courts, sentencing, ASBOs and prisons."},
 {:id=>"driving",
  :title=>"Driving",
  :description=>
   "Book your driving test or get a tax disc online, find out the legal requirements for buying, owning, importing or scrapping a car or motorcycle, and read about your rights and responsibilities as a driver."},
 {:id=>"education",
  :title=>"Education",
  :description=>
   "Get help if you&#39;re at school, planning to go on to further or higher education, looking for training or interested in a student or career development loan."},
 {:id=>"family",
  :title=>"Family",
  :description=>
   "Find out about the laws for getting married/civil partnerships, the process of divorce and separation, parental leave, how to adopt a child, and more."},
 {:id=>"housing",
  :title=>"Housing",
  :description=>
   "Your legal obligations and rights when renting, buying or owning a home, plus information about Council Tax, what to do if you're homeless and where to get help if you have a housing dispute."},
 {:id=>"life-in-the-uk",
  :title=>"Life in the UK",
  :description=>
   "Becoming a British citizen, registering to vote, information about government and the monarchy in the UK, and how to raise an e-petition."},
 {:id=>"money-and-tax",
  :title=>"Money and tax",
  :description=>
   "Find out about pensions, benefits, and what to do if you have debts. Also includes a comprehensive section on tax, including how you pay it and which tax credits you&#39;re eligible for."},
 {:id=>"neighbourhoods",
  :title=>"Neighbourhoods",
  :description=>
   "Report local problems like abandoned vehicles, litter and noise pollution and find out information about your community."},
 {:id=>"travel",
  :title=>"Travel",
  :description=>
   "Plan a journey in the UK, see where you can use your bus pass and find out what you need to do before going abroad."},
 {:id=>"work",
  :title=>"Work",
  :description=>
   "Find out about your rights and responsibilities as an employee, the benefits that can help you get back into work, the National Minimum Wage and your holiday entitlement."},
].each do |details|
  TagRepository.put(
    :tag_type => 'section',
    :tag_id => details[:id],
    :title => details[:title],
    :description => details[:description],
    :parent_id => nil
  )
end
