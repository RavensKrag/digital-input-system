# Find strings of button presses that match certain patterns,
# and fire associated events

require './InputBuffer'

class InputManager
	attr_accessor :input_leniency
	
	def initialize
		# 
		# search for actions by input sequence match?
		# search for actions by name?
		
		
		@buffer = InputBuffer.new 100
		@input_leniency = 80 # milliseconds
		
		@sequences = [] # list of input sequences, sorted from complex to simplistic
	end
	
	def add(sequence)
		# TODO: Properly insert into sorted structure
		@sequences << sequence
	end
	
	def update
		@sequences.each do |s|
			s.update
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
	
	
	[[:down, :press], [:up, :release]].each do |direction, input|
		button_direction = "button_#{direction}"
		
		define_method button_direction do |id|
			@buffer.send button_direction, id
			
			@sequences.each do |s|
				event_sequence = s.send("#{input}_events")
				
				next unless event_sequence
				
				timestamps = @input_buffer.search event_sequence, @input_leniency
				timestamps.each do |time|
					# TODO: Set up state machine so events only trigger when appropriate / sensible
					s.send(input) if recent?(time)
				end
			end
		end
		
	end
	
	
	
	#    __  _              
	#   / /_(_)___ ___  ___ 
	#  / __/ / __ `__ \/ _ \
	# / /_/ / / / / / /  __/
	# \__/_/_/ /_/ /_/\___/ 
	
	def timestamp
		Gosu::milliseconds
	end
	
	def dt
		timestamp - @start_time
	end
	
	private
	
	def recent?(time)
		# dt determines the window
		# dt varies with update rate
		# at the very least, inputs are recent if they were entered
		# within the last few frames or so
		# but real wall clock time is also important
		dt = 0
		
		now = timestamp
		before = now - dt
		
		time.between? before, now
	end
	
end