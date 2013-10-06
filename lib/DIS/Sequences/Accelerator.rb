module DIS
	# Implement the accelerator pattern:
	# press and hold one button, to change the effects of another
	
	class Accelerator < Sequence
		# Accelerator is made up of Sequence objects
		# Assuming it itself is a Sequence, so it can be used in the same way as other Sequences
		# if that is not so, maybe it should only contain Sequences
		
		def initialize(name, *sequences)
			super(name)
			
			@sub_sequences = sequences
		end
		
		def complexity
			return @sub_sequences.inject(0){ |sum, sequence| sum + sequence.complexity }
		end
		
		def trigger_press?(event)
			# press if all sub-sequences have been pressed
			# (AND detection, non-sequential)
			
			
			# if @sub_sequences.all?{ |i| i.active? }
			if @sub_sequences.all?{ |i| i.positive? }
				# this cancel means that the next time buttons are checked, 
				# the Accelerator will not be active
				# but without the cancel, the sub sequences (excluding the last)
				# will continue to fire callbacks (notably the :active state (but also :idle))
				@sub_sequences.each{ |i| i.cancel }
				
				return true
			end
			
			
			return false
		end
		
		def trigger_release?(event)
			# release if any sub-sequences has been released
			# (OR detection)
			if @sub_sequences.any?{ |i| i.negative? }
				reset_search
				
				@release_event = event # store for release callback
				
				return true
			end
			
			
			return false
		end
		
		def reset_search
			
		end
		
		private
		
		def release_callback
			# restore all sub sequences that were canceled as a result of the accelerator
			@sub_sequences.reject{ |i| i.release_events.include? @release_event }.each do |seq|
				seq.press
			end
			
			super()
		end
	end
end