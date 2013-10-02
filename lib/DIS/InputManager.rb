# encoding: utf-8

# Find strings of button presses that match certain patterns,
# and fire associated events

# require './DIS/InputBuffer'
# require './DIS/Sequence'

module DIS
	class InputManager
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
		
		def to_s
			return @sequences.inject(""){|out, i| out << "#{i.to_s}, " }
		end
		
		def inspect
			
		end
		
		def add(sequence)
			# TODO: Properly insert into sorted structure
			@sequences << sequence
			@sequences.sort!# {|x,y| y <=> x}
		end
		
		def reset
			
		end
		
		def update
			# state-maintaining callback should not be made if there is a active sequence of higher complexity
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
			
			
			
			# @sequences.inject(NULL_MAXIMUM_SEQUENCE){ |max, seq| 
			# 	(
			# 			seq.trigger_press? Event.new(id, :down, DIS.timestamp) and 
			# 			seq.complexity > max.complexity
			# 	) ? seq : max
			# }.press
			
			# Sequence#trigger_press? also controls iteration through different events in the sequence across multiple input update ticks
			
			# This assumes that the sequences are not sorted. You can take advantage of sorting the sequences collection by complexity to avoid the :complexity check
				# need to go from simple to complex though, so that complex inputs can be made out of simple ones
			
			# this iteration of the press/release trigger structure ignores that input sequences can contain downs as well as up 
			
			
			
			
			
			
			# queue all things that might need to get pressed
			# sequence_queue =	@sequences.select do |seq|
			# 						seq.trigger_press? Event.new(id, :down, DIS.timestamp)
			# 					end
			
			# sequence_queue.each do |seq|
			# 	seq.press
				
			# 	# press the thing
				
			# 	# cascade the press?
				
				
			# 	# easiest solution is to just arrange the sequences into two groups
			# 	# * accelerators
			# 	# * non-accelerators
			# 	# 
			# 	# then, the 
			# end
			
			
			
			
			
			# it's basically a prefix tree-ish thing
			# and you only want to execute the leaves
			# but I'm trying to do it without a tree
			# (it has no single root, so it's actually just a graph)
			# (you want to select the outside, not the inside)
			# (but it's the same as leaves-not-root thinking)
			
			# kinda valence shell-like
			# you have rings of things at different priorities
			# call the priorities the new "complexty" stat
			
			# complexity of a stand alone element is 1
				# it's actually probably more likely to be the current definition of complexity
				# which depends on the number of input events (both up and down signals)
				
				# well, technically, the simple input is just an event,
				# and complex inputs are sequences
				# in which case this is totally solid
			# the complexity of any complex element is the sum of complexities of all children
			# defined recursively, this means complexity = m, where m = number of descendants
			
			
			
			# projection from outer valence to inner would be really dumb to do as actual graph
				# as in, a structure in a Cartesian plane.
				# I'm just saying, probably don't want to solve graphically
			# can probably just sort by complexity, and then test the high end to the low end?
			# but you want to hit the entire outside layer
			# not necessarily the highest shell
			# but all sequences which are "exposed to air"
			# need to be able to react
			
			# though it may be unnecessary to multi-prong test like this, because only one event is being processed at any one time
			
			# if one event can be found in high and low valence, then only the highest valence should execute -> this is the current behavior
			
			
			
			
			# could just copy the lower-order inputs into the complex one for now
			# but that has the problem of not being able to detect tings like sequences as sub inputs
			
			
			
			# basically, the structure is
			# all basic events need to be arranged in a hyper-sphere
			# such that any two data points
			# are equidistant from each other
			
			
			
			
			# can delay the evaluation of the event until the #update
			# because by then, you will have more info
			# all the data from all button events will be there
			# so you can just use each event as a culling mechanism to remove the ones which are definitely not to fire
			# and then fire whatever's left during the update?
			
			# basically, union-ish to narrow down choices until choice space minimized
			
			# but you need that data oven multiple frames, because the choice space will not always be sufficiently minimized in one frame
			# in fact, that will hardly ever happen
			
			
			
			
			
			
			
			# simplest solution:
			# shift to 4 state machine by turning transitions into states
			# side effect: :press lingers for one update tick
			# not going to notice any change in program state until the next update/draw cycle anyway
			
			# this is weird though, because it means that you need to test for both :press and :active states
			
			# I suppose you can conceal the actual state and keep the same interface
			
			
			
			# the true solution is to project from highest valence shell inward,
			# executing transitions only for the highest relevant valence shell
			# a simpler (though less efficient) solution is to run a two-pass algorithm:
			# 1) start from the center shell, and mark all relevant sectors to the outer shell
			# 2) start from the outside, and unmark all occluded sectors from lower shells
			# now, only the highest relevant shells will be marked
				# the mark/unmark structure has the side effect of allowing input canceling
				# simply remember to unmark before the callbacks are actually processed
			
			
			
			
			
			# # Assume: @sequences should be sorted from low to high complexity
			# event = Event.new(id, :down, DIS.timestamp)
			
			# # mark relevant sectors, inside to outside (low to high)
			# sorted_sequences = @sequences
			
			# marked =	sorted_sequences.select do |sequence|
			# 				sequence.trigger_press? event
			# 			end
			
			# # unmark occluded sectors from lower shells (search high to low)
			# # (marked should be in low-to-high order, so flip it)
			# marked = marked.reverse!.to_set
			
			# 	marked.each do |sequence|
			# 		# remove occluded sub sequences
			# 		# this is the easiest sort of occlusion to remove
			# 		if sequence.respond_to? :sub_sequences
			# 			sequence.sub_sequences.each do |sub_seq|
			# 				marked.delete sub_seq
			# 			end
			# 		end
			# 	end
			
			# marked = marked.to_a
			
			# # execute highest relevant valence shell
			# marked.sort!.last.press
			
			
			
			
			# Assume: @sequences should be sorted from low to high complexity
			event = Event.new(id, :down, DIS.timestamp)
			
			# --- mark relevant sectors, inside to outside (low to high)
			sorted_sequences = @sequences
			
			marked =	sorted_sequences.select do |sequence|
							if sequence.trigger_press? event
								sequence.press
								
								true
							else
								false
							end
						end
			
			# --- unmark occluded sectors from lower shells (search high to low)
			# (marked should be in low-to-high order, so flip it)
			
			marked.pop # get rid of the last one (the only one which should actually transition)
			# unmark the rest
			marked.each do |sequence|
				sequence.cancel
			end
			
			# --- execute highest relevant valence shell
			# execution should already by queued because of Sequence#press in first phase
			
			# ==> this implementation is pretty good, but it neglects to cancel Sequences which are occluded, but do not contain the event currently being processed.
			# ex) 	shift + click occludes both shift and click
			# 		if click is pressed second, the "click" events will not fire, due to occlusion
			# 		however, the shift events are still firing
			# 
			# 		this seems to be the responsibility of the complex event to cancel though,
			# 		which is trivially implemented now, as input canceling was already necessary
			# NOTE: this has already been implemented in Accelerator
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