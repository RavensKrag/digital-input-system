# Find strings of button presses that match certain patterns,
# and fire associated events

require './InputBuffer'

class InputManager
	def initialize
		# 
		# search for actions by input sequence match?
		# search for actions by name?
		
		
		@buffer = InputBuffer.new 100
		
		
		@events = [] # list of events, sorted from complex to simplistic
		
		
	end
	
	def update
		@buffer.update
		
		
		
		
		
		# establish some callbacks, such that when the inputs are detected in the buffer,
		# they can be dealt with
		falling_stab = [Gosu::KbDown, Gosu::KbB]
		
		if @input_buffer.search falling_stab
			# perform some action
		end
		
		
		
		
		# separate button down / up triggers
		@events.each do |event|
			[:press, :release].each do |type|
				@input_buffer.search event.send("#{type}_trigger") do |time|
					# TODO: Set up state machine so events only trigger when appropriate / sensible
					event.send "#{type}_event" if recent?(time)
				end
			end
		end
		
		
		
		
		# search always returns array instead of sometimes having a block
		@events.each do |event|
			[:press, :release].each do |type|
				timestamps = @input_buffer.search event.send("#{type}_trigger")
				timestamps.each do |time|
					# TODO: Set up state machine so events only trigger when appropriate / sensible
					event.send "#{type}_event" if recent?(time)
				end
			end
		end
		
		
		
		# ==========	CRITICAL		==========
		# search for more complex inputs before more simplistic ones
		# this prevents the need to start and then cancel simple inputs
		# or do double pass - id and then trigger
		# or other such inefficient things
		# 
		# sounds like a sorted collection to me
		# 	insert new element to maintain sorted order
		# 	traverse all elements in collection each update
		# what makes an input more complex?
		# 	certainly longer input strings are more complex
		# 
		# 	probably sequences have priority over chords,
		# 	but technically sequences have more inputs (count ups and downs)
	end
	
	def button_down(id)
		@buffer.button_down id
	end
	
	def button_up(id)
		@buffer.button_up id
	end
end