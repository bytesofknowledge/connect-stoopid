module ConnectStoopid
	VERSION = "0.1.4"

	require 'savon'
	require 'rexml/document'
	require 'connect-stoopid/reporting-client'
	require 'connect-stoopid/time-entry'

  # The WSDL and the SOAP client currently need to be accessible by the API classes.
  class << self; attr_accessor :wsdl end
  class << self; attr_accessor :soap_client end

  # The methods defined need to be accessible and instance methods of the ConnectStoopid module.
  class << self
  	##
  	# Parameters:
  	# 	psa_address -- The hostname of your ConnectWise PSA, ie. con.companyconnect.net
  	# 	company -- Company id used when logging into ConnectWise
  	# 	username -- ConnectWise Integration username
  	# 	password -- ConnectWise Integration password
  	# 	options -- Override the default ReportingClient options
  	##
  	def connect(company, username, password, options = {})
  		@company  = company
  		@username = username
  		@password = password

  		@client_options = {
  			:client_logging       => true,
  			:client_logging_level => :error,
  			:soap_version         => 2,
  			:soap_logging         => false,
  			:soap_logging_level   => :fatal
  		}
  		@client_options.merge!(options)

  		@soap_client = Savon.client({
  			:wsdl         => @wsdl,
  			:soap_version => @client_options[:soap_version],
  			:log          => @client_options[:soap_logging],
  			:log_level    => @client_options[:soap_logging_level]
  		})
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
  				"CompanyId"          => @company,
  				"IntegratorLoginId"  => @username,
  				"IntegratorPassword" => @password
  			}
  		}
  		return request_options
  	end
  
  	private

  	LOG_LEVELS = {
  		:debug    => 1,
  		:standard => 2,
  		:error    => 3
  	}

  	def logging
  		return @client_options[:client_logging]
  	end

  end
end