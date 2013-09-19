# Queues up items, discarding the oldest item when the size is reached

class RingBuffer
	# add new elements to the back of the line
	# walk from the front to the back
	
	def initialize(size)
		@queue = Array.new(size)
		@head_index = 0
		@tail_index = @head_index
		
		@size = 0
	end
	
	def clear
		@queue.clear
		@head_index = 0
		@tail_index = @head_index
		
		@size = 0
	end
	
	def empty?
		@size == 0
	end
	
	# Walk the whole buffer (do not loop)
	# Each goes from new -> old
	# reverse_each goes from old -> new
	# TODO: Make it so that #each can return an iterator if no block supplied, like in Array#each
	def each(start=0)
		counter = wrapping_counter @head_index, @tail_index, @queue.size
		counter[start..-1].each do |i|
			yield @queue[i]
		end
	end
	
	def each_with_index(start=0)
		index = 0
		
		counter = wrapping_counter @head_index, @tail_index, @queue.size
		counter[start..-1].each do |i|
			yield @queue[i], index
			
			index += 1
		end
	end
	
	# Iterate over each pairwise combination of elements
	def each_pair
		# Ruby defines #combination and #permutation for iteration of those sorts of sets
		
		# counter = wrapping_counter @head_index, @tail_index, @queue.size
		
		# counter.each_index do |index|
		# 	i = counter[index]
			
		# 	counter[(index+1)..-1].each do |j|
		# 		yield @queue[i], @queue[j]
		# 	end
		# end
		
		# using #permutation means that the order will not be guaranteed
		wrapping_counter(@head_index, @tail_index, @queue.size).permutation(2) do |i, j|
			yield @queue[i], @queue[j]
		end
	end
	
	# add items to the back of the queue
	def queue(*items)
		items.each do |i|
			@queue[@tail_index] = i
			advance_tail
			
			
		end
	end
	
	# take items out of the front of the queue
	def dequeue(iterations=1)
		out = Array.new
		
		iterations.times do
			# get item from the front
			out << @queue[@head_index]
			# remove item from the queue
			@queue[@head_index] = nil
			# move the front
			advance_head
			
			# reduce size
			@size -= 1
		end
		
		
		if out.size == 1
			return out.first
		else
			return out
		end
	end
	
	def head
		@queue[@head_index]
	end
	
	def tail
		@queue[tail_index]
	end
	
	
	private
	
	
	def wrapping_counter(head, tail, size, &block)
		# size is the size of the entire container, not the interval between head and tail
		raise "Head out of range" if head >= size or head < 0
		raise "Tail out of range" if tail >= size or tail < 0
		
		return if size == 0
		return if head == tail # traversal range is zero
		
		out = Array.new unless block # if there is no block, return a list a numbers
		
		
		i = head
		
		final = tail+1
		final = 0 if final == size
		begin # can't just say "< tail" because of wrap around
			
			if block
				block.call i 
			else
				out << i
			end
			
			i += 1
			i = 0 if i == size
		end while(i != final) 
		
		return out unless block # <- only return list if there isn't a block
	end
	
	
	
	# Move head to the next position. Don't forget to wrap around.
	def advance_head
		@head_index += 1
		@head_index = 0 if @head_index == @queue.size
	end
	
	# Move head to the previous position. Don't forget to wrap around.
	def regress_head
		# @queue[@head_index] = nil
		# @size -= 1 unless @size == 0
		
		# @head_index -= 1
		# @head_index = @queue.size-1 if @head_index < 0
	end
	
	# Move tail to the next position. Don't forget to wrap around.
	def advance_tail
		# circular overwrite
		if @size == @queue.size
			# buffer is at full capacity
			# tail should be right up against the head at this point
			# the only way new elements can come in, is if old ones are expired
			# so move the head (which points to the oldest element) forward to make space
			advance_head
		else
			@size += 1
		end
		
		# move index
		@tail_index += 1
		@tail_index = 0 if @tail_index == @queue.size
	end
	
	def regress_tail
		# @queue[@tail_index] = nil
		# @size -= 1 unless @size == 0
		
		# @tail_index -= 1
		# @tail_index = @queue.size-1 if @tail_index < 0
	end
end