require 'net/http'


h = Net::HTTP.new('lib-ts-mads.vm.duke.edu', 8983)

id_list = ['000000050']

id_list.each { |id_num|
  http_response = h.get("/solr/holdings/select?q=id:#{id_num}")
  response = eval(http_response.body)
  doc = response[:response][:docs]
  puts doc[0][:id]

}
