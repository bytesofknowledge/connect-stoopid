Gem::Specification.new do |spec|
	spec.name           = "connect-stoopid"
	spec.version        = "0.2.0"
	spec.date           = "2013-10-02"
	spec.summary        = "Abstracts interaction with the ConnectWise Reporting and Time APIs"
	spec.description    = "Simple Ruby client handling access to the ConnectWise SOAP APIs"
	spec.authors        = ["Josh Stump"]
	spec.email          = "websupport@bytesofknowledge.com"
	spec.homepage       = "https://github.com/bytesofknowledge/connect-stoopid"
	spec.require_paths  = ["lib"]
	spec.files          = [
													"./lib/connect-stoopid.rb",
													"./lib/connect-stoopid/reporting-client.rb"
	]
	spec.license        = "GPL-2"
	
	spec.add_dependency('savon', '>= 2.2.0')
end