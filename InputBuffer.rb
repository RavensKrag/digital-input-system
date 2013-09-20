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
	
	
	def initialize
		@buffer = RingBuffer.new 100
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
	def search(*inputs)
		[
			Input.new(Gosu::KbA, :down,	0),
			Input.new(Gosu::KbA, :up,	200)
		]
		
		string_buffer = @buffer.to_s
		
		# match - button press
		# match without the timestamps, and then collect up all the timestamps
		# basically, search for inputs, to find timestamps
		# compare timestamps to get time deltas
		# compare time deltas to DTs of keys
		# match found 
		# 	inputs[0].to_s but strip the dt off the end (match any dt)
		# 	any sequence
		# 	inputs[1].to_s but strip the dt off the end (match any dt)
		
		
		data_regex = /.*?[↑|↓]/
		
		# match 0 or more of any character (non greedy), followed by up/down arrow, then digits
		# scan can return multiple matches
		data, dt = inputs[0].to_s.scan(/#{data_regex})(\d*)/).first
		
		
		search_regex = /#{data}(\d*)[,#{data_regex}[\d*],]*/
		# next part of the regex, is the same idea again, but with the next data chunk
		# captures should find DTs
		# will be chunked by the data it matches up with
		# ie) each match returned by scan will be one set which matches the requested buttons
		string_buffer.scan(search_regex) do |event_time_deltas|
			# match up found deltas with expected deltas
			# check exact, or within certain margins, whatever you need
			# (depends on input type (simple / complex, and which complex one))
		end
		
		
		
		
		
		
		
		# The following regex all assumes that the button up / down events
		# will be represented in string form as the Unicode up/down arrows
		data_regex_string = '.*?[↑|↓]'
		
		search_query = inputs.collect do |query_input|
			data = query_input.to_s.scan(/(#{data_regex_string})\d*/).first
			
			# look for the exact data match,
			# CAPTURE the number which follows,
			# 
			# might be some other inputs in the middle (don't care about those)
			# all inputs are separated with commas
			# TODO: Remove blob to detect middle inputs if possible. Would make the main query regex cleaner, and would also allow for making the input scan regex constant.
			data+'(\d*)' +'[,#{data_regex_string}[\d*],]*'
		end
		
		# query_string = search_query.join
		# query_regex = Regex.new query_string
		query_regex = Regex.new search_query.join
		
		@buffer.to_s.scan(query_regex) do |event_time_deltas|
			# match up found deltas with expected deltas
			raise inputs.size != event_time_deltas.size # should totally be the same
			
			
			inputs.each_index do |i|
				expected_dt = inputs[i].dt
				match_dt = event_time_deltas[i]
				
				# check exact, or within certain margins, whatever you need
				# (depends on input type (simple / complex, and which complex one))
				
				
				# MAYBE JUST YIELD HERE? IDK o_O;
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