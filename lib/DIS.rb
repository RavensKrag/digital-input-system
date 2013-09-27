#~ require 'DIS/DIS' # Load c extension files

Dir.chdir File.dirname(__FILE__)

require './DIS/Sequence'
require './DIS/Event'
require './DIS/Input'
require './DIS/InputManager'
require './DIS/InputBuffer'


module DIS
	def self.timestamp
		message = "DIS needs to know how you keep time. Please define self.timestamp for DIS::Module"
		
		raise "\n-----\n#{message}\n-----\n"
	end
end