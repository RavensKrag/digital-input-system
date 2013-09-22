# Find strings of button presses that match certain patterns,
# and fire associated events

require './InputBuffer'

class InputManager
	def initialize
		# 
		# search for actions by input sequence match?
		# search for actions by name?
		
		
		@buffer = InputBuffer.new 100
		
		
		@events = []
		
	end
	
	def update
		@buffer.update
		
		
		
		
		
		# establish some callbacks, such that when the inputs are detected in the buffer,
		# they can be dealt with
		falling_stab = [Gosu::KbDown, Gosu::KbB]
		
		if @input_buffer.search falling_stab
			# perform some action
		end
		
		
		
		triggers = Array.new # list of triggers such as the example above
		triggers.each do |t|
			if @input_buffer.search t
				# perform action associated with trigger
				
			end
		end
		
		
		
		# Using a hash like this assumes that all callbacks have unique triggers
		# if the trigger is only the button binding, this is not true
		# each trigger should be unique,
		# but I don't want to have to specify a unique trigger when I create an action
		# triggers need to be reassigned at will
		# triggers should probably be reassiged in some graphical format, 
		# that way I can get more feedback about the system I'm trying to design
		
		actions = Hash.new # trigger => callback
		actions.each do |trigger, callback|
			if @input_buffer.search trigger
				callback.call
			end
		end
		
		
		
		
		
		
		
		actions = Array.new # contains input objects which monitor state and callbacks
		actions.each do |input_object|
			# NOTE: search needs to return when the triggers were found, not just if one or more were discovered
			# TODO: Make sure that #search returns multiple items if many 
			if @input_buffer.search input_object.trigger
				callback.call
			end
		end
		
		
		
		
		# trigger and callback are related to each other
		# trigger can change fluidly
		# how do you id the action when the trigger can change?
		# 	can you give it a name?
		
		[name, trigger, callback]
		name => [trigger, callback] # want to search easily by name to change the trigger
		
		
		if @input_buffer.search trigger
			callback.call
		end
		
		
		
		
		# this search structure mirrors the string regex search syntax, but not sure if natural
		event = nil
		if @input_buffer.search event.trigger
			event.run_callback
		end
		
		
		
		
		
		
		# make sure it didn't expire or something
		event = nil
		
		timestamps = @input_buffer.search event.trigger
		timestamps.each do |time|
			# traversing timestamps from old to new
			# but aren't more recent timestamps more relevant?
		end
		
		# check if the most recent timestamp is within the time threshold
		# TODO: remove old inputs (clear buffer up until that timestamp) (maybe problems?)
		
		event.run_callback
		
		
		
		
		
		
		event = nil
		@input_buffer.search event.trigger do |time|
			# execute event if the trigger occurred recently
			if recent?(time)
			# dt = timestamp - time
			# dt < RECENTNESS_THRESHOLD # <- different for different events?
				event.run_callback
			end
		end
		
		
		
		
		
		
		events = Array.new # list of events, sorted by complex to simplistic
		events.each do |event|
			@input_buffer.search event.trigger do |time|
				# execute event if the trigger occurred recently
				if recent?(time) # time.recent? would be more natural
				# dt = timestamp - time
				# dt < RECENTNESS_THRESHOLD # <- different for different events?
				# TODO: make sure it degrades gracefully with lag
					event.run_callback
				end
			end
		end
		
		
		
		
		
		
		# separate button down / up triggers
		events = Array.new # list of events, sorted by complex to simplistic
		events.each do |event|
			[:press, :release].each do |type|
				@input_buffer.search event.send("#{type}_trigger") do |time|
					# TODO: Set up state machine so events only trigger when appropriate / sensible
					event.send "#{type}_event" if recent?(time)
				end
			end
		end
		
		
		
		
		# search always returns array instead of sometimes having a block
		events = Array.new # list of events, sorted by complex to simplistic
		events.each do |event|
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