# encoding: utf-8

# Find strings of button presses that match certain patterns,
# and fire associated events

require './InputBuffer'

module DIS
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
			@sequences.sort! {|x,y| y <=> x}
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
		
		def button_down(id)
			@buffer.button_down id
			
			# Out of all tracked sequences, find any that could be relevant
			# out of all relevant ones, execute the most complex sequence
			
			candidates = @sequences.collect do |s|
				event_sequence = s.press_events
				
				next unless event_sequence
				
				# look for all of the events, in the order specified
				timestamp = @buffer.search event_sequence, @input_leniency
				
				next unless timestamp
				
				# either collect this sequence, or nil
				s if recent?(timestamp)
			end
			
			candidates.compact!
			
			most_complex_candidate = candidates.max_by(&:complexity)
			most_complex_candidate.press if most_complex_candidate
		end
		
		def button_up(id)
			@buffer.button_up id
			
			@sequences.each do |s|
				event_sequence = s.release_events
				
				next unless event_sequence
				
				# look for any one of the events, instead of all of them at once
				timestamps =	event_sequence.collect do |event|
									# Remember that #search can return nil
									@buffer.search [event], @input_leniency
								end
				
				# fire event if any of the timestamps happened recently
				s.release if timestamps.compact.any?{ |time| recent?(time) }
			end
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
			
			# now = DIS.timestamp
			# before = now - dt
			
			# puts "#{before} < #{time} < #{now}"
			
			# time.between? before, now
			
			
			
			puts "#{DIS.timestamp-time} ~~~ #{dt}"
			(DIS.timestamp-time) < dt
		end
		
	end
end