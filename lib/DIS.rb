#~ require 'DIS/DIS' # Load c extension files

require 'DIS/InputManager'
require 'DIS/InputBuffer'
require 'DIS/Sequence'
require 'DIS/Event'

module DIS
	def self.timestamp
		message = "DIS needs to know how you keep time. Please define self.timestamp for DIS::Module"
		
		raise "\n-----\n#{message}\n-----\n"
	end
end