=begin
	ConnectStoopid::TimeEntry
	Provides an interface to the ConnectWise Time Entry API
=end

module ConnectStoopid
  class TimeEntry
    
    def initialize(psa_address, company, username, password, options = {})
      ConnectStoopid.wsdl = "https://#{psa_address}/v4_6_release/apis/1.5/TimeEntryApi.asmx?wsdl"
      ConnectStoopid.connect(company, username, password, options)
    end
  
  	##
  	# Parameters:
  	# 	options: Key value pairs to add to the Savon SOAP request
  	# Returns:
    #   Error on failure, returns true on addition of time entry.
  	##
  	def add_time_entry(
      options = {
        "MemberID"   => "testuser",
        "ChargeCode" => "Automated (testuser)",
        "WorkType"   => "Regular",
        "DateStart"  => "",
        "TimeStart"  => "",
        "TimeEnd"    => "",
        "Notes"      => "",
      }
    )
  		ConnectStoopid.log_client_message("Adding a Time Entry | Member: #{options['MemberID']} Start: #{options['TimeStart']} End: #{options['TimeEnd']}", :debug)

  		request_options = ConnectStoopid.base_soap_hash
  		request_options.merge!({ "timeEntry" => options })
		
  		begin
  			response = ConnectStoopid.soap_client.call(:add_time_entry, :message => request_options)
  		rescue Savon::SOAPFault => error
  			log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
  		else
  			if response.success?
          result = true
        else
          result = false
  			end
  		end
      return result
  	end
  end

end
