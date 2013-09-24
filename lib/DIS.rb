#~ require 'DIS/DIS' # Load c extension files
module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end