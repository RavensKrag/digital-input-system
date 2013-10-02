module DIS
	# Implement the accelerator pattern:
	# press and hold one button, to change the effects of another
	
	class Accelerator < Sequence
		# Accelerator is made up of Sequence objects
		# Assuming it itself is a Sequence, so it can be used in the same way as other Sequences
		# if that is not so, maybe it should only contain Sequences
		
		def initialize(name, *sequences, &block)
			super(name, &block)
			
			@sub_sequences = sequences
		end
		
		def complexity
			return @sub_sequences.inject(0){ |sum, sequence| sum + sequence.complexity }
		end
		
		def trigger_press?(event)
			# press if all sub-sequences have been pressed
			# (AND detection, non-sequential)
			
			# puts "#{@name} down"
			
			# pressed_string = @sub_sequences.inject("") do |out, i|
			# 	out << "#{i.name} #{i.active?}, "
			# end
			
			# puts pressed_string
			
			
			# if @sub_sequences.all?{ |i| i.active? }
			if @sub_sequences.all?{ |i| i.positive? }
				puts "YAY"
				
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
				
				return true
			end
			
			
			return false
		end
		
		def reset_search
			
		end
	end
end