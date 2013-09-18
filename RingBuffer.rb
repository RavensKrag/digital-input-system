# Queues up items, discarding the oldest item when the size is reached

class RingBuffer
	def initialize(size)
		@queue = Arary.new(size)
		@head_index = 0
	end
	
	# Walk the whole buffer (do not loop)
	# TODO: Make it so that #each can return an iterator if no block supplied, like in Array#each
	def each
		head_to_end = (@head_index..(@queue.size-1)).to_a
		start_to_tail = (0..tail_index).to_a
		
		(head_to_end + start_to_tail).each do |i|
			item = @queue[i]
			
			unless item.nil?
				yield item 
			else
				break # stop loop when you hit a nil
			end
		end
	end
	
	def push(*items)
		items.each do |i|
			advance_head
			@queue[@head_index] = i
		end
	end
	
	def pop(iterations=1)
		raise "Must pop at least once" if iterations < 1
		raise "Can't pop more times than there are items" if iterations > @queue.size
		
		output = Array.new
		
		iterations.times do
			output << head
			
			regress_head
		end
		
		
		if output.size == 1
			return output.first
		else
			return output
		end
	end
	
	def head
		@queue[@head_index]
	end
	
	def tail
		@queue[tail_index]
	end
	
	
	private
	
	# def wrapping_increment(i)
	# 	i += 1
	# 	i = 0 if i == @queue.size
		
	# 	return i
	# end
	
	# def wrapping_decrement(i)
	# 	i -= 1
	# 	i = @queue.size-1 if i < 0
		
	# 	return i
	# end
	
	
	
	# Move head to the next position. Don't forget to wrap around.
	def advance_head
		@head_index += 1
		@head_index = 0 if @head_index == @queue.size
	end
	
	# Move head to the previous position. Don't forget to wrap around.
	def regress_head
		@head_index -= 1
		@head_index = @queue.size-1 if @head_index < 0
	end
	
	def tail_index
		i = @head_index - 1
		i = @queue.size-1 if i < 0
		
		return i
	end
end