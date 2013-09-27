# encoding: utf-8

# Find strings of button presses that match certain patterns,
# and fire associated events

# require './DIS/InputBuffer'
# require './DIS/Sequence'

module DIS
	class InputManager
		NullMaximumSequence = Naught.build{ |n| n.mimic DIS::Sequence }
		def NullMaximumSequence.complexity
			-1 # lower than the normal possibly complexity
		end
		
		NULL_MAXIMUM_SEQUENCE = Struct.new(:complexity) do
			def trigger_press?
				
			end
			
			def press
				
			end
		end.new(-1) # set complexity lower than the normal possibly complexity
		
		
		attr_accessor :input_leniency
		
		def initialize
			# 
			# search for actions by input sequence match?
			# search for actions by name?
			
			
			@input_leniency = 80 # milliseconds
			
			
			# --- list of input sequences, sorted from complex to simplistic
			@sequences = []
		end
		
		def add(sequence)
			# TODO: Properly insert into sorted structure
			@sequences << sequence
			@sequences.sort! {|x,y| y <=> x}
		end
		
		def reset
			
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
			# Out of all tracked sequences, find any that could be relevant
			# out of all relevant ones, execute the most complex sequence
			
			# iterate from the most simplistic input to the most complex
				# because you can have a complex input made of simple ones
			# collect all sequences that can intercept this input
			# out of those, allow the most complex input to actually fire callbacks
				# other inputs should still transition, but not fire
				# ex)	assume a single button A, and a combo(A,B,C)
				# 		if A is depressed, I want the single button to know,
				# 		although the single button should not fire any callbacks.
				# 
				# 		alternatively, it's easier to not have the button transition,
				# 		as it means that you don't have to stop the :hold or :release events,
				# 		just the :press event
			
			
			
			
			
			# put the button into a buffer for each sequence
			# when the buffer for a particular sequence fills up, that sequence is ready to go
				# clear buffer if any of the "release" events are triggered
				# make sure you hit the #release event as well
			# out of all the sequences that are ready, only execute the one with highest complexity
			
			
			
			# consider
			# ex) chord(abc) ---> release(b) -> single(a)
			# what's to keep the single from triggering after part of the chord is released, but the requirements for the single are still met?
			
			
			
			@sequences.inject(NULL_MAXIMUM_SEQUENCE){ |max, seq| 
				(
						seq.trigger_press? Event.new(id, :down, DIS.timestamp) and 
						seq.complexity > max.complexity
				) ? seq : max
			}.press
			
			# Sequence#trigger_press? also controls iteration through different events in the sequence across multiple input update ticks
			
			# This assumes that the sequences are not sorted. You can take advantage of sorting the sequences collection by complexity to avoid the :complexity check
			
			# this iteration of the press/release trigger structure ignores that input sequences can contain downs as well as up 
			
		end
		
		def button_up(id)
			# @sequences.each do |seq|
			# 	if seq.trigger_release? Event.new(id, :up, DIS.timestamp)
			# 		seq.release
			# 	end
			# end
			
			
			# @sequences.each do |seq|
			# 	seq.trigger_press? Event.new(id, :up, DIS.timestamp)
			# end
			
			# now sequences can't trigger on up
			# instead, you have to define a release callback sequence
			# if you can define triggers on up, then #press will be called on up, and #release will be called by down, which is really bizarre
			# also, many games which use up events, use them as charged abilities
			
			# NOTE: this means that if you try to define a callback with just a release event, you should probably check when adding it to the manager if there is already an event with just a down, and no up.  Might be some way to merge those things.
				# this should probably wait until the more advanced tree-like sequence handling
			
			
			
			
			# what order should things fire in?
			# is stopping the event string more important than logging the event?
			# are both equally important?
			# 
			# triggering the release seems more important, because if an event triggers the release, it will reset the entire chain.
			# at that point, it's not necessary to process the press as part of the input sequence
				# would just put it in to take it out
				# or try to put it in, when you know it's not gonna go in
			
			event = Event.new(id, :up, DIS.timestamp)
			
			@sequences.each do |seq|
				if seq.trigger_release? event
					seq.release
				else
					# will not trigger :press events on :up,
					# but does not prevent them from being defined
					seq.trigger_press? event
				end
			end
		end
	end
end