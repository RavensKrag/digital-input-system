# encoding: utf-8

require './RingBuffer'

class InputBuffer
	Input = Struct.new :key, :direction, :dt do
		def to_s
			out = ""
			out << self.key.to_s
			
			out << case self.direction
				when :up
					"↑"
				when :down
					"↓"
			end
			
			out << self.dt.to_s
			
			return out
		end
	end
	
	
	def initialize(size=100)
		@buffer = RingBuffer.new size # buffered input stream
		reset
		
		# should be in same units as other time units
		# assuming milliseconds
		@input_leniancy = 80
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
		
		char = $window.button_id_to_char(id)
		@buffer.queue Input.new(char, :down, dt) if char
	end
	
	def button_up(id)
		char = $window.button_id_to_char(id)
		@buffer.queue Input.new(char, :up, dt) if char
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
	def search(inputs)
		# search string version of input buffer with regex to collect all key press timestamps
		# based on the button inputs supplied to this method
		match_timestamps = Array.new # output
		
		
		# The following regex all assumes that the button up / down events
		# will be represented in string form as the Unicode up/down arrows
		data_regex_string = '.*?[↑|↓]'
		
		# Format the given button inputs as a search query
		search_query = inputs.collect do |query_input|
			data = query_input.to_s.scan(/(#{data_regex_string})\d*/).first
			
			# look for the exact data match,
			# CAPTURE the number which follows,
			# 
			# might be some other inputs in the middle (don't care about those)
			# all inputs are separated with commas
			# TODO: Remove blob to detect middle inputs if possible. Would make the main query regex cleaner, and would also allow for making the input scan regex constant.
			data+'(\d*)' + '[,'+data_regex_string+'][\d*],]*'
			# data+'(\d*)' + ',.*?'
		end
		
		query_regex = Regex.new search_query.join
		
		
		match_timestamps = Array.new
		
		@buffer.to_s.scan(query_regex).inject(match_timestamps) do |out, event_timestamps|
			# NOTE: Assuming integer timestamps
			
			# match up found deltas with expected deltas
			raise "Somehow regex matched against sequence of different size." if inputs.size != event_timestamps.size # should totally be the same
			
			event_timestamps.collect!{ |timestamp| timestamp.to_i } # convert strings
			
			# expected DTs are given with dt=0 being the first button press
			
			match_dts = event_timestamps.collect{ |timestamp| timestamp - event_timestamps.first }
			expected_dts = inputs.collect{ |i| i.dt }
			
			
			deltas = match_dts.zip(expected_dts)
			if deltas.all?{ |match, expected| match.between? expected, expected+@input_leniancy }
				out << event_timestamps.last
			end
		end
		
		match_timestamps = nil if match_timestamps.empty?
		
		return match_timestamps
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