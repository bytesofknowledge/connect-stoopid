=begin
	ConnectStoopid::ReportingClient
	Provides an interface to the ConnectWise Reporting API
=end

module ConnectStoopid
	class ReportingClient
		
		##
		# Parameters:
		# 	psa_address -- The hostname of your ConnectWise PSA, ie. con.companyconnect.net
		# 	company -- Company id used when logging into ConnectWise
		# 	username -- ConnectWise Integration username
		# 	password -- ConnectWise Integration password
		# 	options -- Override the default ReportingClient options
		##
		def initialize(psa_address, company, username, password, options = {})
			@wsdl     = "https://#{psa_address}/v4_6_release/apis/1.5/ReportingApi.asmx?wsdl"
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
			}) do
				convert_request_keys_to :camelcase
			end
		end

		##
		# Parameters:
		# 	none
		# Returns:
		# 	[String]
		##
		def get_all_report_types
			log_client_message("Getting list of report types", :debug)

			request_options = base_soap_hash
			
			response = @soap_client.call(:get_reports, :message => request_options)

			if response.success?
				report_types = []
				xml_doc = REXML::Document.new(response.to_xml)
				REXML::XPath.each(xml_doc, "//Report") do |report|
					report_types << report.attributes["Name"].to_s
				end
				return report_types.sort
			end
		end

		##
		# Parameters:
		# 	options: Key value pairs to add to the Savon SOAP request
		# 		For this request, options must include :report_name => "Some_Report"
		# Returns:
		# 	[String]
		##
		def get_all_report_fields(options = {})
			log_client_message("Getting list of available fields for a given report type", :debug)

			request_options = base_soap_hash
			request_options.merge!(options)

			response = @soap_client.call(:get_report_fields, :message => request_options)

			if response.success?
				report_fields = []
				xml_doc = REXML::Document.new(response.to_xml)
				REXML::XPath.each(xml_doc, "//FieldInfo") do |field|
					report_fields << field.attributes["Name"].to_s
				end
				return report_fields.sort
			end
		end

		##
		# Parameters:
		# 	options: Key value pairs to add to the Savon SOAP request
		# 		For this request, options must include :report_name => "Some_Report",
		# 		and should probably include :conditions => "some condition set"
		# Returns:
		# 	Integer
		##
		def run_report_count(options = {})
			log_client_message("Getting a count of records per a set of conditions", :debug)

			request_options = base_soap_hash
			request_options.merge!(options)

			response = @soap_client.call(:run_report_count, :message => request_options)

			if response.success?
				xml_doc = REXML::Document.new(response.to_xml)
				return REXML::XPath.first(xml_doc, "//RunReportCountResult").text.to_i
			end
		end

		##
		# Parameters:
		# 	options: Key value pairs to add to the Savon SOAP request
		# 		For this request, options must include :report_name => "Some_Report",
		# 		and should probably (read: definitely) include :conditions => "some condition set"
		# Returns:
		# 	[{key => value, key => value}]
		##
		def run_report_query(options = {})
			log_client_message("Running full query per a set of conditions", :debug)

			request_options = base_soap_hash
			request_options.merge!(options)

			response = @soap_client.call(:run_report_query, :message => request_options)

			if response.success?
				xml_doc = REXML::Document.new(response.to_xml)
				rows = []
				REXML::XPath.each(xml_doc, "//ResultRow") do |row|
					row_key_vals = {}
					REXML::XPath.each(row, "Value") do |col|
						row_key_vals[col.attributes["Name"].to_s] = col.text.to_s
					end
					rows << row_key_vals
				end
				return rows
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
					puts "#{self.class.to_s.split('::').last} Logger -- #{message}"
				end
			end
		end

		def base_soap_hash
			request_options = {
				:credentials => {
					:company_id => @company,
					:integrator_login_id => @username,
					:integrator_password => @password
				}
			}
			return request_options
		end
	end
end