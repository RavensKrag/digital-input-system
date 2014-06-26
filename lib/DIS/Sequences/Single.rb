module DIS
	# Shorthand when you want to just track one button
	
	class Single < Sequence
		def initialize(name, button_id)
			super(name)
			
			
			@press_events = [
				DIS::Event.new(button_id, :down)
			]
			@release_events = [
				DIS::Event.new(button_id, :up)
			]
		end
	end
end