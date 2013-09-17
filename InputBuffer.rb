# encoding: utf-8

class Array
	def each_pair
		self.each_index.each do |i|
			((i+1)..(self.size-1)).each do |j|
				
				yield self[i], self[j]
				
			end
		end
	end
end

class InputBuffer
	Input = Struct.new :key, :direction, :dt
	
	
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
		queue = []
		
		@buffer.each_index.each do |i|
			pair_found = false
			
			((i+1)..(@buffer.size-1)).each do |j|
				first = @buffer[i]
				second = @buffer[j]
				
				
				if first.key == second.key and first.direction == :down && second.direction == :up
					queue << [first.dt, second.dt]
					
					pair_found = true
					break
				end
				
				
			end
			
			# Could not find a match for this one.
			# If it's a down event, that means it's an ongoing press
			time_event = @buffer[i]
			if !pair_found and time_event.direction == :down
				queue << [time_event.dt, dt]
			end
		end
		
		queue.each_with_index do |point_data, i|
			# draw one line each iteration
			first_dt, second_dt = point_data
			
			# scale = 1.to_f/10
			scale = 1
			
			
			points = [
				CP::Vec2.new(first_dt*scale, 0),
				CP::Vec2.new(second_dt*scale, 0)
			]
			
			points.each do |point|
				point.y += 30 * i
			end
			
			draw_line points[0], points[1], 10
		end
	end
	
	
	def button_down(id)
		@start_time = timestamp if @buffer.empty?
		
		char = $window.button_id_to_char(id)
		@buffer << Input.new(char, :down, dt) if char
	end
	
	def button_up(id)
		char = $window.button_id_to_char(id)
		@buffer << Input.new(char, :up, dt) if char
	end
	
	def reset
		@buffer.clear
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