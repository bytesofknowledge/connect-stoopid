=begin
	ConnectStoopid::ReportingClient
	Provides an interface to the ConnectWise Reporting API
	Read-only access to ConnectWise data from most systems
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
				# Client options, can be overridden per request
				:client_logging => true,
				:client_logging_level => :error,
				:return_raw_xml => false,
				# Savon options, can only be set at initialization
				:soap_version => 2,
				:soap_logging => false,
				:soap_logging_level => :fatal
			}
			@client_options.merge!(options)

			@client_options_backup = {}

			@soap_client = Savon.client({
				:wsdl => @wsdl,
				:soap_version => @client_options[:soap_version],
				:log => @client_options[:soap_logging],
				:log_level => @client_options[:soap_logging_level]
			})
		end

		##
		# Parameters:
		# 	include_fields -- Boolean to include available fields with each report
		# 	options -- request specific options
		# Returns:
		# 	If the include_fields is set to "false", returns an array of strings containing all report names in alphabetical order
		# 	If set to "true", returns an array of hashes of format {:report_name => "Activity", :fields => ["field1", "field2", ...]}
		##
		def get_all_report_types(include_fields = false, options = {})
			backup_client_options(options)
			log_client_message("Getting list of report types, includeFields = #{include_fields}", :debug)

			request_options = base_soap_hash
			request_options.merge!({'includeFields' => include_fields.to_s})
			
			begin
				response = @soap_client.call(:get_reports, :message => request_options)
			rescue Savon::SOAPFault => error
				log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
			rescue Excon::Errors::Timeout => error
				log_client_message("Error -- Request Timeout", :error)
			else
				if response.success?
					if @client_options[:return_raw_xml]
						return response
					else
						report_types = []
						xml_doc = REXML::Document.new(response.to_xml)
						if !include_fields
							REXML::XPath.each(xml_doc, '//Report') do |report|
								report_types << report.attributes['Name'].to_s
							end
							return report_types.sort
						else
							REXML::XPath.each(xml_doc, '//Report') do |report|
								report_fields = []
								REXML::XPath.each(report, 'Field') do |field|
									report_fields << field.attributes['Name'].to_s
								end
								report_types << {:report_name => report.attributes['Name'], :fields => report_fields}
							end
							return report_types.sort_by! {|x| x[:report_name]}
						end
					end
				end
			ensure
				restore_client_options
			end
		end

		##
		# Parameters:
		# 	report_name -- String name of the CW report to retrieve fields for
		# 	options -- request specific options
		# Returns:
		# 	[String]
		##
		def get_all_report_fields(report_name, options = {})
			backup_client_options(options)
			log_client_message("Getting list of available fields for the #{report_name} report", :debug)

			request_options = base_soap_hash
			request_options.merge!({'reportName' => report_name})

			begin
				response = @soap_client.call(:get_report_fields, :message => request_options)
			rescue Savon::SOAPFault => error
				log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
			rescue Excon::Errors::Timeout => error
				log_client_message("Error -- Request Timeout", :error)
			else
				if response.success?
					if @client_options[:return_raw_xml]
						return response
					else
						report_fields = []
						xml_doc = REXML::Document.new(response.to_xml)
						REXML::XPath.each(xml_doc, '//FieldInfo') do |field|
							report_fields << field.attributes['Name'].to_s
						end
						return report_fields.sort
					end
				end
			ensure
				restore_client_options
			end
		end

		##
		# Parameters:
		# 	report_name -- String name of the CW report to retrieve fields for
		# 	conditions -- String of conditions to apply to the report
		# 	options -- request specific options
		# Returns:
		# 	Integer
		##
		def run_report_count(report_name, conditions = '', options = {})
			backup_client_options(options)
			log_client_message("Getting a count of #{report_name} records per a set of conditions", :debug)

			request_options = base_soap_hash
			request_options.merge!({'reportName' => report_name, 'conditions' => conditions})

			begin
				response = @soap_client.call(:run_report_count, :message => request_options)
			rescue Savon::SOAPFault => error
				log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
			rescue Excon::Errors::Timeout => error
				log_client_message("Error -- Request Timeout", :error)
			else
				if response.success?
					if @client_options[:return_raw_xml]
						return response
					else
						xml_doc = REXML::Document.new(response.to_xml)
						return REXML::XPath.first(xml_doc, '//RunReportCountResult').text.to_i
					end
				end
			ensure
				restore_client_options
			end
		end

		##
		# Parameters:
		# 	report_name -- String name of the CW report to retrieve fields for
		# 	conditions -- String of conditions to apply to the report
		# 	order_by -- String containing field and direction by which to order results
		# 	limit -- Integer limit for the SQL query
		# 	skip -- Integer number of rows of results to skip before beginning to return results
		# 	options -- request specific options
		# Returns:
		# 	[{field1 => value1, field2 => value2}]
		##
		def run_report_query(report_name, conditions = '', order_by = '', limit = '', skip = '', options = {})
			backup_client_options(options)
			log_client_message("Running full #{report_name} query per a set of conditions", :debug)

			request_options = base_soap_hash
			user_options = {'reportName' => report_name}
			conditions != '' ? user_options['conditions'] = conditions : nil
			order_by != '' ? user_options['orderBy'] = order_by : nil
			limit != '' ? user_options['limit'] = limit : nil
			skip != '' ? user_options['skip'] = skip : nil
			request_options.merge!(user_options)

			begin
				response = @soap_client.call(:run_report_query, :message => request_options)
			rescue Savon::SOAPFault => error
				log_client_message("SOAP Fault\nError Message:\n#{error}", :error)
			rescue Excon::Errors::Timeout => error
				log_client_message("Error -- Request Timeout", :error)
			else
				if response.success?
					if @client_options[:return_raw_xml]
						return response
					else
						xml_doc = REXML::Document.new(response.to_xml)
						rows = []
						REXML::XPath.each(xml_doc, '//ResultRow') do |row|
							row_key_vals = {}
							REXML::XPath.each(row, 'Value') do |col|
								row_key_vals[col.attributes['Name'].to_s] = col.text.to_s
							end
							rows << row_key_vals
						end
						return rows
					end
				end
			ensure
				restore_client_options
			end
		end

		private
		LOG_LEVELS = {
			:debug => 1,
			:standard => 2,
			:error => 3
		}

		def backup_client_options(temp_options)
			@client_options_backup = @client_options.clone
			@client_options.merge!(temp_options)
		end

		def restore_client_options
			@client_options = @client_options_backup.clone
		end

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
				'credentials' => {
					'CompanyId' => @company,
					'IntegratorLoginId' => @username,
					'IntegratorPassword' => @password
				}
			}
			return request_options
		end
	end
end
