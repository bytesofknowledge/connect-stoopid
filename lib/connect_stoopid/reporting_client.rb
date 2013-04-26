=begin

=end
module ConnectStoopid
	class ReportingClient
		def initialize(psa_address, company, username, password, options = {})
			@wsdl     = "https://#{psa_address}/v4_6_release/apis/1.5/ReportingApi.asmx?wsdl"
			@company  = company
			@username = username
			@password = password

			@client_options = {
				:soap_version => 2,
				:client_logging => false,
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

		def get_all_report_types
			request_options = base_soap_hash

			response = @soap_client.call(:get_reports, :message => request_options)

			if response.success?
				report_types = []
				xml_doc = Document.new(response.to_xml)
				XPath.each(xml_doc, "//Report") do |report|
					report_types << report.attributes["Name"].to_s
				end
				return report_types.sort
			end
		end

		def get_all_report_fields(options = {})
			request_options = base_soap_hash
			request_options.merge!(options)

			response = @soap_client.call(:get_report_fields, :message => request_options)

			if response.success?
				report_fields = []
				xml_doc = Document.new(response.to_xml)
				XPath.each(xml_doc, "//FieldInfo") do |field|
					report_fields << field.attributes["Name"].to_s
				end
				return report_fields.sort
			end
		end

		def run_report_count(options = {})
			request_options = base_soap_hash
			request_options.merge!(options)

			response = @soap_client.call(:run_report_count, :message => request_options)

			if response.success?
				xml_doc = Document.new(response.to_xml)
				return XPath.first(xml_doc, "//RunReportCountResult").text.to_i
			end
		end

		def run_report_query(options = {})
			request_options = base_soap_hash
			requst_options.merge!(options)

			response = @soap_client.call(:run_report_query, :message => request_options)

			if response.success?
				#
			end
		end

		private
		def logging
			return @client_options[:client_logging]
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