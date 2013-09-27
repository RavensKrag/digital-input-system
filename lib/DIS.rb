#~ require 'DIS/DIS' # Load c extension files

# Dir.chdir File.dirname(__FILE__)

require_relative './DIS/Sequence'
require_relative './DIS/Event'
require_relative './DIS/Input'
require_relative './DIS/InputManager'
require_relative './DIS/InputBuffer'


module DIS
	def self.timestamp
		message = "DIS needs to know how you keep time. Please define self.timestamp for DIS::Module"
		
		raise "\n-----\n#{message}\n-----\n"
	end
end