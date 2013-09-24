# encoding: utf-8

# Queues up items, discarding the oldest item when the size is reached
module DIS
	class RingBuffer
		include Enumerable
		
		# add new elements to the back of the line
		# walk from the front to the back
		
		attr_reader :size
		
		def initialize(size)
			@queue = Array.new(size)
			@head_index = 0
			@tail_index = @head_index
			
			@size = 0
		end
		
		def [](index)
			# returns nil if index >= @size
			# does work with negative indexes as in Array though
			counter = wrapping_counter @head_index, @tail_index, @queue.size
			i = counter[index]
			if i
				return @queue[i]
			else
				return nil
			end
			
			
			# # wraps around the entire buffer (including empty slots)
			# # would have to at least modify so that it only iterates over filled slots
			# i = @head_index + index
			# i %= @queue.size if i >= @queue.size
			
			# return @queue[i]
		end
		
		# Comma separated list of inputs
		def to_s
			# out = ""
			
			# self.each do |i|
			# 	out << i.to_s
			# 	out << ','
			# end
			
			
			
			# self.each do |i|
			# 	out << "#{i},"
			# end
			
			# return out
			
			return self.inject(""){|out, i| out << "#{i},"}
		end
		
		def clear
			@queue = Array.new @queue.size # TODO: find a way to optimize this (clear doesn't work)
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
			
			counter = counter[start..-1] if start != 0
			
			counter.each do |i|
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
			# insert @ tail
			# increment size (if able)
			# check size
				# move head if necessary
			# move tail
			
			items.each do |i|
				# puts "head #{@head_index}  tail #{@tail_index}"
				
				@queue[@tail_index] = i
				
				@size += 1 unless @size == @queue.size
				
				if @size == @queue.size
					advance_head
				end
				
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
		
		
		# Exclude the tail, because the tail is always an open slot,
		# thus, there will be no valid data there
		def wrapping_counter(head, tail, size, &block)
			# size is the size of the entire container, not the interval between head and tail
			raise "Head out of range" if head >= size or head < 0
			raise "Tail out of range" if tail >= size or tail < 0
			
			out = Array.new unless block # if there is no block, return a list a numbers
			
			
			i = head
			
			final = tail
			while(i != final)  # can't just say "< tail" because of wrap around
				if block
					block.call i 
				else
					out << i
				end
				
				i += 1
				i = 0 if i == size
			end 
			
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
end