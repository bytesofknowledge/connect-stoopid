=begin
	ConnectStoopid::ReportingClient
	Provides an interface to the ConnectWise Reporting API
=end

module ConnectStoopid
	class TimeEntry
		
		##
		# Parameters:
		# 	psa_address -- The hostname of your ConnectWise PSA, ie. con.companyconnect.net
		# 	company -- Company id used when logging into ConnectWise
		# 	username -- ConnectWise Integration username
		# 	password -- ConnectWise Integration password
		# 	options -- Override the default ReportingClient options
		##
		def initialize(psa_address, company, username, password, options = {})
			@wsdl     = "https://#{psa_address}/v4_6_release/apis/1.5/TimeEntryApi.asmx?wsdl"
			@company  = company
			@username = username
			@password = password

			@client_options = {
				:client_logging => true,
				:client_logging_level => :error,
				:soap_version => 2,
				:soap_logging => false,
				:soap_logging_level => :fatal
			}
			@client_options.merge!(options)

			@soap_client = Savon.client({
				:wsdl => @wsdl,
				:soap_version => @client_options[:soap_version],
				:log => @client_options[:soap_logging],
				:log_level => @client_options[:soap_logging_level]
			})
		end

		##
		# Parameters:
		# 	options: Key value pairs to add to the Savon SOAP request
		# Returns:
    #   Error on failure, prints 'Success!' on addition of time entry.
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
			log_client_message("Adding a Time Entry | Member: #{options['MemberID']} Start: #{options['TimeStart']} End: #{options['TimeEnd']}", :debug)

			request_options = base_soap_hash
			request_options.merge!({ "timeEntry" => options })
			
			begin
				response = @soap_client.call(:add_time_entry, :message => request_options)
			rescue Savon::SOAPFault => error
				log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
			else
				if response.success?
          print 'Success!'
				end
			end
		end

		private
		LOG_LEVELS = {
			:debug => 1,
			:standard => 2,
			:error => 3
		}

		def logging
			return @client_options[:client_logging]
		end

		def log_client_message(message, level = :error)
			if logging
				if LOG_LEVELS[level] >= LOG_LEVELS[@client_options[:client_logging_level]]
					puts "#{self.class.to_s.split("::").last} Logger -- #{message}"
				end
			end
		end

		def base_soap_hash
			request_options = {
				"credentials" => {
					"CompanyId" => @company,
					"IntegratorLoginId" => @username,
					"IntegratorPassword" => @password
				}
			}
			return request_options
		end
	end
end
