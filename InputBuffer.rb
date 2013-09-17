# encoding: utf-8

class InputBuffer
	def initialize
		@buffer = Array.new
		reset
	end
	
	def to_s
		return @buffer.to_s
	end
	
	def inspect
		return @buffer.inspect
	end
	
	def draw
		# queue = []
		
		# @buffer.each_index.each do |i|
		# 	(i..(@buffer.size-1).each do |j|
				
		# 		first = @buffer[i]
		# 		second = @buffer[j]
				
		# 		if first[0] == second[0]
		# 			queue << [first, second]
					
					
		# 			break
		# 		end
				
		# 	end
		# end
		
		# queue.each_index do |i|
		# 	first, second = queue[i]
			
		# 	p0 = first.split[1].to_i
		# 	p1 = first.split[1].to_i
			
		# 	[p0, p1].each do |point|
		# 		point.y += 10 * i
		# 	end
			
		# 	draw_line p0, p1, 5
		# end
	end
	
	
	def button_down(id)
		char = $window.button_id_to_char(id)
		@buffer[]
	end
	
	def button_up(id)
		char = $window.button_id_to_char(id)
		
	end
	
	
	def append(id, direction_mark)
		char = $window.button_id_to_char(id)
		@buffer << char + direction_mark + " " + dt.to_s if char
	end
	
	def reset
		@buffer.clear
		
		@start_time = timestamp
	end
	
	def timestamp
		Gosu::milliseconds
	end
	
	def dt
		timestamp - @start_time
	end
	
	
	
	
	def draw_line(p0, p1, width, z=0, color=0xffffffff)
		# NOTE: Line represented as quad, but will not always fit tight in a AABB
		
		normal = (p1 - p0).normalize.perp
		
		half_width = width/2
		corners = [
			p0 + normal*half_width,
			p1 + normal*half_width,
			p1 - normal*half_width,
			p1 - normal*half_width,
		]
		
		$window.draw_quad	corners[0].x, corners[0].y, color, 
							corners[1].x, corners[1].y, color, 
							corners[2].x, corners[2].y, color, 
							corners[3].x, corners[3].y, color, 
							z
	end
end