Input = Struct.new :button, :direction do
	def to_s
		direction_string << case self.direction
			when :up
				"↑"
			when :down
				"↓"
		end
		
		return "#{self.button}#{direction_string}"
	end
end