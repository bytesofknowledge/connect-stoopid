Gem::Specification.new do |s|
	s.name          = "connect_stoopid"
	s.version       = "0.0.1"
	s.date          = "2013-04-26"
	s.summary       = "Run queries against the ConnectWise Reporting SOAP API"
	s.description   = "Simple Ruby client handling access to the ConnectWise SOAP APIs"
	s.authors       = ["Josh Stump"]
	s.email         = "joshua.t.stump@gmail.com"
	s.files         = %w(
											lib/connect_stoopid.rb,
											lib/connect_stoopid/reporting_client.rb
	)
	s.homepage      = ""
	s.license       = "GPL-2"
	s.require_paths = ["lib"]
end