class Event
	attr_reader :input, :timestamp
	
	def initialize(button, direction, timestamp=0)
		@input = Input.new(button, direction)
		@timestamp = timestamp
	end
	
	def to_s
		"#{@input}#{@timestamp}"
	end
end