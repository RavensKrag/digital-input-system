# encoding: utf-8

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
		@sequences.sort!
	end
	
	def reset
		@buffer.reset
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
			puts direction
			
			@buffer.send button_direction, id
			
			@sequences.each do |s|
				event_sequence = s.send("#{input}_events")
				
				next unless event_sequence
				
				# @buffer.search event_sequence, @input_leniency do |timestamp|
				# 	s.send(input) if recent?(timestamp)
				# end
				
				
				# @buffer.search event_sequence, @input_leniency, :reverse do |timestamp|
				# 	if recent?(timestamp)
				# 		s.send(input) 
						
				# 		# will only break if new enough input found
				# 		# will not break if inputs are over threshold
				# 		break
				# 	else
				# 		break
				# 	end
				# end
				
				# @buffer.search event_sequence, @input_leniency, :reverse do |timestamp|
				# 	s.send(input) if recent?(timestamp)
					
				# 	# really only want the most recent one,
				# 	# there's no way older ones would be more relevant
				# 	# as the only relevant ones are the ones that happened recently
				# 	break
				# end
				
				
				
				
				timestamp = @buffer.search event_sequence, @input_leniency
				if timestamp
					s.send(input) if recent?(timestamp)
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
	
	private
	
	def recent?(time)
		# dt determines the window
		# dt varies with update rate
		# at the very least, inputs are recent if they were entered
		# within the last few frames or so
		# but real wall clock time is also important
		
		# TODO: tweak dt
		# dt = 550
		# dt = 500
		# dt = 300
		# dt = 360
		dt = 380
		
		# now = timestamp
		# before = now - dt
		
		# puts "#{before} < #{time} < #{now}"
		
		# time.between? before, now
		
		puts "#{timestamp-time} ~~~ #{dt}"
		(timestamp-time) < dt
	end
	
end