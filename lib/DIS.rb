#~ require 'DIS/DIS' # Load c extension files
module DIS
	def self.timestamp
		message = "DIS needs to know how you keep time. Please define self.timestamp for DIS::Module"
		
		raise "\n-----\n#{message}\n-----\n"
	end
end