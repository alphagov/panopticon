namespace :needs do
                                       
  require 'csv'       
  require 'ansi/code'
   
  task :import_csv => :environment do
    
    @artefacts = CSV.read( File.join( Rails.root, 'lib', 'import', '20111121_need_ids.csv' ) ).collect{ |row| { :artefact_id => row[0].to_i, :need_id => row[2] } }
    @artefacts.each_with_index do |a, i|              
      puts "[#{i+1}/#{@artefacts.size}] Looking for artefact #{a[:artefact_id]}..."
      record = Artefact.find(a[:artefact_id].to_i) rescue nil     
                              
      if (a[:need_id].match(/delete/i) rescue false)
        print "\t----> #{ANSI.cyan('Need is marked for deletion, skipping.')}\n"
      elsif a[:need_id].to_i == 0
        print "\t----> #{ANSI.red('No need ID specified in the CSV.')}\n"
      elsif record
        print "\t----> Updating artefact #{a[:artefact_id]}: "
        if record.update_attribute('need_id', a[:need_id])   
          print ANSI.green("Success!\n")
        else
          print ANSI.red("Failed\n")
        end      
      else
        print "\t----> #{ANSI.red('Could not find artefact.')}\n"
      end    
    end                                                                             
  end
  
end