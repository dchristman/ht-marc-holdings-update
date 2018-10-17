#necessary imports
require 'net/http'
require 'marc'

class HoldingMarc
  attr_accessor :id, :first_ind, :sf_b, :sf_h, :sf_i
  def initialize(holding_json)
    @id = holding_json[:id]
    @first_ind = holding_json[:field_852_ind][0] != nil ? holding_json[:field_852_ind][0] : " "
    @sf_b = holding_json[:field_852_b] != nil ? holding_json[:field_852_b][0] : " "
    @sf_h = holding_json[:field_852_h] != nil ? holding_json[:field_852_h][0] : " "
    @sf_i = holding_json[:field_852_i] != nil ? holding_json[:field_852_i][0] : " "
  end
end

#open file of holding numbers
holding_number_file = File.open("ht-large-test.txt")

#set solr strings
solr_base = Net::HTTP.new('lib-ts-mads.vm.duke.edu', 8983)
solr_bibliographic_search = '/solr/bibliographic/select?q=field_001:'
solr_holding_search = '/solr/holdings/select?q=id:'

#create MARC Writer
writer = MARC::Writer.new("output.txt")

#read file block
holding_number_file.each_line { |holding_number|

  #get JSON of holding record (9 digit)
  holding_http = solr_base.get(solr_holding_search + holding_number.strip)
  holding_response = eval(holding_http.body)
  holding_json = holding_response[:response][:docs][0]

  #get JSON of bib record
  biblipgraphic_http = solr_base.get(solr_bibliographic_search + holding_json[:field_004][0])
  bibliographic_response = eval(biblipgraphic_http.body)
  bibliographic_json = bibliographic_response[:response][:docs][0]

  #create new marc record
  holding_record = MARC::Record.new()

  #add necessary fields
  holding_marc = HoldingMarc.new(holding_json)
  holding_record.append(MARC::ControlField.new('001',holding_marc.id))

  holding_record.append(MARC::DataField.new('852', holding_marc.first_ind, ' ', ['b',holding_marc.sf_b], ['c', 'KEEPR'],['h', holding_marc.sf_h],['i', holding_marc.sf_i]))

  #Add record to Writer
  writer.write(holding_record)

#next line in file block
}

#save writer to marc File
writer.close()

#holding_marc class
