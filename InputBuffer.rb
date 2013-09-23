# encoding: utf-8

require './RingBuffer'

class Regexp
  def +(r)
    Regexp.new(source + r.source)
  end
end



class InputBuffer
	DEFAULT_LENIANCY = 80	# should be in same units as other time units
							# assuming milliseconds
	
	def initialize(size=100)
		@buffer = RingBuffer.new size # buffered input stream
		reset
	end
	
	#    ____        __              __ 
	#   / __ \__  __/ /_____  __  __/ /_
	#  / / / / / / / __/ __ \/ / / / __/
	# / /_/ / /_/ / /_/ /_/ / /_/ / /_  
	# \____/\__,_/\__/ .___/\__,_/\__/  
	#               /_/                 
	
	def to_s
		return @buffer.to_s
	end
	
	def inspect
		return @buffer.inspect
	end
	
	def draw
		queue = []
		
		
		@buffer.each_pair do |first, second|
			if first.key == second.key and first.direction == :down && second.direction == :up
				queue << [first.dt, second.dt]
				
				pair_found = true
				break
			end
		end
		
		
		
		# @buffer.each_with_index do |first_item, i|
		# 	pair_found = false
			
		# 	@buffer.each_with_index i do |second_item, j|
		# 		queue << [first.dt, second.dt]
				
		# 		pair_found = true
		# 		break
		# 	end
			
		# 	# Could not find a match for this one.
		# 	# If it's a down event, that means it's an ongoing press
		# 	time_event = @buffer[i]
		# 	if !pair_found and time_event.direction == :down
		# 		queue << [time_event.dt, dt]
		# 	end
		# end
		
		
		
		queue.each_with_index do |point_data, i|
			# draw one line each iteration
			first_dt, second_dt = point_data
			
			scale = 1.to_f/2
			# scale = 1
			
			
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
	
	#     __  ___      _       __        _          _____            __               
	#    /  |/  /___ _(_)___  / /_____ _(_)___     / ___/__  _______/ /____  ____ ___ 
	#   / /|_/ / __ `/ / __ \/ __/ __ `/ / __ \    \__ \/ / / / ___/ __/ _ \/ __ `__ \
	#  / /  / / /_/ / / / / / /_/ /_/ / / / / /   ___/ / /_/ (__  ) /_/  __/ / / / / /
	# /_/  /_/\__,_/_/_/ /_/\__/\__,_/_/_/ /_/   /____/\__, /____/\__/\___/_/ /_/ /_/ 
	#                                                 /____/                          
	
	# TODO: Consider just sticking the string in the buffer instead of the input object
	# if string match algorithms are going to be used to match,
	# and a actual string is going to be used to match
	# might be better to keep things as strings for most of the process
	def button_down(id)
		@start_time = timestamp if @buffer.empty?
		
		@buffer.queue Event.new(id, :down, dt)
	end
	
	def button_up(id)
		@buffer.queue Event.new(id, :up, dt)
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
	
	
	# search through the input buffer for something that matches the supplied input sequence
	def search(inputs, input_leniancy=DEFAULT_LENIANCY, iteration_direction=:forward)
		# search string version of input buffer with regex to collect all key press timestamps
		# based on the button inputs supplied to this method
		
		iteration_method =	if iteration_direction == :forward
								:each
							elsif(
								iteration_direction == :reverse ||
								iteration_direction == :backwards
								)
								:reverse_each
							else
								raise "Improper iteration direction in #{self.class}#search"
							end
		
		# NOTE: Following regex may be wonky on the comma detection
		# NOTE: Regex currently doesn't care if you try ↓↑ ↓↑ ↓↑, for 3 button chord, because it sees the 3 downs in a row with some stuff in the middle
		
		# Format the given button inputs as a search query
		search_query = inputs.collect do |query_event|
			 /#{query_event.input.to_s}(\d*)/ + /[,.*?[↑|↓][\d*],]*?/
		end
		
		query_regex = search_query.inject(//){|out, i| out + i}
		
		

		regex_matches = @buffer.to_s.scan(query_regex)
		# p "size: #{@buffer.size}  contents: #{@buffer}"
		# p regex_matches
		regex_matches.send(iteration_method) do |event_timestamps|
			# match up found deltas with expected deltas
			raise "Somehow regex matched against sequence of different size." if inputs.size != event_timestamps.size # should totally be the same
			
			# NOTE: Assuming integer timestamps
			event_timestamps.collect!{ |timestamp| timestamp.to_i } # convert strings
			
			# expected DTs are given with dt=0 being the first button press
			
			match_times = event_timestamps.collect{ |t| t - event_timestamps.first }
			expected_times = inputs.collect{ |i| i.timestamp }
			
			
			times = match_times.zip(expected_times)
			if times.all?{ |match, expected| match.between? expected, expected+input_leniancy }
				yield event_timestamps.last
			end
		end
	end
	
	
	private
	
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