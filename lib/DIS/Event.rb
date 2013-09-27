# encoding: utf-8

require 'DIS/Input'

module DIS
	class Event
		attr_reader :input, :timestamp
		
		def initialize(button, direction, timestamp=0)
			@input = Input.new(button, direction)
			@timestamp = timestamp
		end
		
		def to_s
			"#{@input}#{@timestamp}"
		end
		
		def ==(other)
			return super(other) unless other.is_a? self.class
			
			# return (self.input == other.input and self.timestamp == other.timestamp)
			
			# TODO: Sort out this comparison, and the related Sequence@release_events#include?
			# the above implementation is more correct
			# the below implementation makes the relevant #include? call work correctly
			
			return (self.input == other.input)
		end
	end
end