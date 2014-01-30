=begin
	ConnectStoopid::Company
	Provides an interface to the ConnectWise Time Entry API
=end

module ConnectStoopid
  class Company
    
    def initialize(psa_address, company, username, password, options = {})
      ConnectStoopid.wsdl = "https://#{psa_address}/v4_6_release/apis/1.5/CompanyApi.asmx?wsdl"
      ConnectStoopid.connect(company, username, password, options)
    end
  
  	##
  	# Parameters:
  	# 	options: Key value pairs to add to the Savon SOAP request
  	# Returns:
    #   False on failure, an array of companies on success.
  	##
  	def find_companies(options = {})
  		ConnectStoopid.log_client_message("FindCompanies", :debug)

  		request_options = ConnectStoopid.base_soap_hash
  		request_options.merge!(options)
		
  		begin
  			response = ConnectStoopid.soap_client.call(:find_companies, :message => request_options)
  		rescue Savon::SOAPFault => error
  			ConnectStoopid.log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
  		else
  			if response.success?
          companies = []
          xml_doc   = REXML::Document.new(response.to_xml)
          #REXML::XPath.each(xml_doc, "//Company") do |company|
          #  companies << company 
          #end
          result = xml_doc
        else
          result = false
  			end
  		end
      return result
  	end

  	##
  	# Parameters:
  	# 	options: Key value pairs to add to the Savon SOAP request
  	# Returns:
    #   False on failure, an array of companies on success.
  	##
  	def get_company(id)
  		ConnectStoopid.log_client_message("GetCompany", :debug)

  		request_options = ConnectStoopid.base_soap_hash
  		request_options.merge!(
        { "id" => id }
      )
		
  		begin
  			response = ConnectStoopid.soap_client.call(:get_company, :message => request_options)
  		rescue Savon::SOAPFault => error
  			ConnectStoopid.log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
  		else
  			if response.success?
          xml_doc   = REXML::Document.new(response.to_xml)
          result = xml_doc
        else
          result = false
  			end
  		end
      return result
  	end


  end
end
