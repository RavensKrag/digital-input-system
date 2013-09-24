require File.expand_path("../lib/DIS/version", __FILE__)

ENABLE_C_EXTENSION = false

Gem::Specification.new do |s|
	s.name        = "DIS"
	s.version     = DIS::VERSION
	s.date        = '2012-07-17'
	s.platform    = Gem::Platform::RUBY
	s.authors     = ["Raven"]
	s.email       = 'AvantFlux.Raven@gmail.com'
	s.homepage    = 'https://github.com/RavensKrag'
	
	s.summary     = "High-level digital input management."
	s.description = <<EOS
	High-level system for searching for sequences of digital inputs, 
	and firing associated events.
EOS
	
	s.required_rubygems_version = ">= 1.3.6"
	
	# lol - required for validation
	#~ s.rubyforge_project         = "newgem"
	
	# If you have other dependencies, add them here
	s.add_dependency "state_machine", "~> 1.2.0"
	
	if ENABLE_C_EXTENSION
		s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
		s.extensions = ['ext/DIS/extconf.rb']
	else
		s.files = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
	end
	puts s.files
	
	s.require_path = 'lib'
	
	# If you need an executable, add it here
	# s.executables = ["newgem"]
end
