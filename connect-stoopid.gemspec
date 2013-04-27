Gem::Specification.new do |s|
	s.name          = "connect-stoopid"
	s.version       = "0.0.1"
	s.date          = "2013-04-26"
	s.summary       = "Run queries against the ConnectWise Reporting SOAP API"
	s.description   = "Simple Ruby client handling access to the ConnectWise SOAP APIs"
	s.authors       = ["Josh Stump"]
	s.email         = "joshua.t.stump@gmail.com"
	s.files         = [
											"lib/connect-stoopid.rb",
											"lib/connect-stoopid/reporting-client.rb"
	]
	s.homepage      = ""
	s.license       = "GPL-2"
	s.require_paths = ["lib"]
end