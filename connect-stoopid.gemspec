Gem::Specification.new do |spec|
	spec.name           = "connect-stoopid"
	spec.version        = "0.1.4"
	spec.date           = "2014-01-30"
	spec.summary        = "Run queries against the ConnectWise SOAP API"
	spec.description    = "Simple Ruby client handling access to the ConnectWise SOAP APIs"
	spec.authors        = ["Josh Stump"]
	spec.email          = "websupport@bytesofknowledge.com"
	spec.homepage       = "https://github.com/bytesofknowledge/connect-stoopid"
	spec.require_paths  = ["lib"]
	spec.files          = [
													"./lib/connect-stoopid.rb",
													"./lib/connect-stoopid/reporting-client.rb",
													"./lib/connect-stoopid/time-entry.rb"
	]
	spec.license        = "GPL-2"
	
	spec.add_dependency('savon', '>= 2.2.0')
end
