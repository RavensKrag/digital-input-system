#!/usr/bin/env ruby
# encoding: utf-8

class Window
	def initialize
		@input_manager = InputManager.new
		
		@input_manager.event :dive_attack do
			bind_to [:down, :b]
			
			
		end
	end
	
	def update
		@input_manager.update
		
		
		
		
	end
	
	def button_down(id)
		@input_manager.button_down id
	end
	
	def button_up(id)
		@input_manager.button_up id
	end
end

# good for typing it out, but this library needs to be controlled programatically
InputManager.new do
	sequence :dive_attack do
		press_string = [
			Event.new(:down_arrow, :down, 0),
			Event.new(:down_arrow, :down, 80)
		]
		
		
		press_string [
			Event.new(:down_arrow, :down, 0),
			Event.new(:down_arrow, :down, 80)
		]
		
		
		press_string = [
			Event.new(:down_arrow, :down, 0),
			Event.new(:down_arrow, :down, 80)
		]
		
		release_string do
			
		end
	end
end


# better programmatic control, but it's a bit messier
inpman = InputManager.new

sequence = Sequence.new :dive_attack
sequence.press_string = [
	Event.new(:down_arrow, :down, 0),
	Event.new(:down_arrow, :down, 80)
]


inpman.add sequence


# redefinition syntax
inpman[:dive_attack].press_string = [
	
]
# this is problematic if the inputs are being sorted by complexity
# the easiest system to implement would be to force the user to re-add
# the sequence when changing it, but that's an awkward interface

# would be best to get the system to auto rebalance

# could force a rebalance on the whole system at the end
# 	that would be less efficient, but "cleaner" interface
# 	similar to the problem of having to "pack" in a typical GUI framework





sequence = Sequence.new :dive_attack do
	# most likely, the events firing should not change after the initial definition
	on_press do
		
	end
	
	on_hold do
		
	end
	
	on_release do
		
	end
	
	on_idle do
		
	end
end




# look for all of these inputs, in the order specified
sequence.press_events = [
	Event.new(Gosu::KbA, :down,	0+300*0),
	Event.new(Gosu::KbA, :up,	200+300*0),
	
	Event.new(Gosu::KbO, :down,	0+300*1),
	Event.new(Gosu::KbO, :up,	200+300*1),
	
	Event.new(Gosu::KbE, :down,	0+300*2)
]

# release event timestamps are irrelevant
# release event fire when any one of the release events are detected
sequence.release_events = [
	Event.new(Gosu::KbE, :up,	0)
]








arp_chord.press_events = [
	Event.new(Gosu::KbA, :down,	0),
	Event.new(Gosu::KbO, :down,	100),
	Event.new(Gosu::KbE, :down,	200)
]
arp_chord.release_events = [
	Event.new(Gosu::KbA, :up,	0),
	Event.new(Gosu::KbO, :up,	0),
	Event.new(Gosu::KbE, :up,	0)
]




chord.press_events = [
	Event.new(Gosu::KbA, :down,	0),
	Event.new(Gosu::KbO, :down,	0),
	Event.new(Gosu::KbE, :down,	0)
]
chord.release_events = [
	Event.new(Gosu::KbA, :up,	0),
	Event.new(Gosu::KbO, :up,	0),
	Event.new(Gosu::KbE, :up,	0)
]




new_sequence = sequence + SequencePause.new(20) + chord
new_sequence = sequence+SequenceHold.new(300) + Rest.new(10) + chord
	sequence+SequenceHold.new(300)
	# takes the sequence, creates a new sequence with no release,
	# where the press string = original string + original release offset by hold time
	
	sequence + Rest.new(10)



roll*3 + Rest.new(100) + chord

	


complex = ComplexSequence.new(
	[sequence, 0, 10],
	[chord, ]
)










# the release sequence is always a sequence of :up events at the end
# if there are multiple :up events
	# if they are at the same time
		# the release only triggers on simultaneous release
	# if the times are different
		# release triggers when any one of the specified events is detected


inpman.add sequence






accelerator(a, b, c, d)
accelerator(a) + main # works best if accelerator is the first argument
	accelerator(shift) + click
	
	# can you use the order to attach meaning?
	run + jump
	jump + run
	# clearly, yeah
	
	
	run + jump + kick*2 + jump + dive_kick








# ===== Link one button to many actions
# -- definition
single = DIS::Sequence.new
single.press_events = [
	DIS::Event.new(Gosu::KbD, :down)
]
single.release_events = [
	DIS::Event.new(Gosu::KbD, :up)
]

# -- linkage
if single.press?		# only will work if :press runs for one tick before other phases trigger
	
end



single.on_press do		# need a way to add and remove callbacks from this structure easily
	this
	that
	the_other
end

single.press_callbacks.add :this do
	# this
end
single.press_callbacks.add :that do
	# that
end
single.press_callbacks.add :the_other do
	# the_other
end
# may want to raise an error if there is already a callback
# with the desired name




single.press_callbacks.delete :this # return removed block
single.press_callbacks.delete :that
single.press_callbacks.delete :the_other


single.press_callbacks.clear # delete all callbacks


single.callbacks.add :this do
	on_press do
		puts "~~~shift start~~~ #{Gosu::milliseconds}"
	end

	on_hold do
		puts "~~~shift~~~ #{Gosu::milliseconds}"
	end

	on_release do
		puts "outie~~"
	end

	on_idle do
		# puts "GOGOGOG!!!!"
	end
end



# could be able to add with the same name, and register new callbacks
