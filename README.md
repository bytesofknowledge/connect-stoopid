connect-stoopid
===============

The aim of connect-stoopid is to simplify interaction with the ConnectWise SOAP APIs. Built on Savon, the "heavy metal SOAP client". Currently, the gem only supports the CW Reporting API, with the addition of other APIs planned as time allows. A note: you should by no means trust what the ConnectWise API documentation says about how SOAP requests should look. 25-50% of the example requests in the documentation are wrong, and attempting to follow them will only lead to a very angry developer. Trust only the information that the WSDL supplies via SoapUI or some similar program.

Installation
------------
    gem install connect-stoopid

Usage
-----
    require 'connect-stoopid'
    cw_client = ConnectStoopid::ReportingClient.new('mycw.install.net', 'my_company', 'my_user', 'my_password')
    report_types = cw_client.get_all_report_types
    puts report_types

Options
-------
When you create a ReportingClient, you can also pass it an options hash as a fifth parameter to override the default client options. The default options are shown below:

    @client_options = {
				:client_logging => true, # Allows the ReportingClient to print occaisional messages
				:client_logging_level => :error, # Allowed values [:debug, :standard, :error]
				:soap_version => 2, # 1 for SOAP 1.1, 2 for SOAP 1.2
				:soap_logging => false, # Whether or not Savon should post log messages
				:soap_logging_level => :fatal # Allowed value [:debug, :warn, :error, :fatal]
		}
