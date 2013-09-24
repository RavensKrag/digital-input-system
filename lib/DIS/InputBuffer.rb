# encoding: utf-8

require './RingBuffer'

class Regexp
  def +(r)
    Regexp.new(source + r.source)
  end
  
  def self.join(expressions)
  	# Regexp.new(expressions.inject(""){|out, e| out + e.source} )
  	Regexp.new(expressions.map{|e| e.source}.join() )
  end
end


module DIS
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
			@start_time = DIS.timestamp if @buffer.empty?
			
			@buffer.queue Event.new(id, :down, dt)
		end
		
		def button_up(id)
			@buffer.queue Event.new(id, :up, dt)
		end
		
		def reset
			@buffer.clear
		end
		
		def dt
			DIS.timestamp - @start_time
		end
		
		
		# search through the input buffer for something that matches the supplied input sequence
		def search(inputs, input_leniancy=DEFAULT_LENIANCY)
			# search string version of input buffer with regex to collect all key press timestamps
			# based on the button inputs supplied to this method
			
			# NOTE: Following regex may be wonky on the comma detection
			# NOTE: Regex currently doesn't care if you try ↓↑ ↓↑ ↓↑, for 3 button chord, because it sees the 3 downs in a row with some stuff in the middle
			
			# Format the given button inputs as a regex query
			search_query = inputs.collect do |query_event|
				/#{query_event.input.to_s}(\d*)/ + /[,.*?[↑|↓][\d*],]*?/ 
			end
			query_regex = Regexp.join(search_query)
			
			
			# query_regex = inputs.inject(//) do |out, query_event|
			# 	out + /#{query_event.input.to_s}(\d*)/ + /[,.*?[↑|↓][\d*],]*?/
			# end
			
			
			
			
			regex_matches = @buffer.to_s.scan(query_regex) # scan from old to recent
			
			return nil if regex_matches.size == 0
			
			most_recent_match = regex_matches.last
			
			most_recent_match.collect!{ |t| t.to_i }
			
			
			
			match_times = most_recent_match.collect{ |t| t - most_recent_match.first }
			expected_times = inputs.collect{ |i| i.timestamp }
			
			times = match_times.zip(expected_times)
			if times.all?{ |match, expected| match.between? expected, expected+input_leniancy }
				return most_recent_match.last # time of final input in sequence
			else
				return nil
			end
			
			
			# the following optimization seems to be about the same speed, maybe even a bit slower
			# certainly much less readable though
			
			# inputs.size.times do |i|
			# 	match = most_recent_match[i] - most_recent_match.first
			# 	expected = inputs[i].timestamp
				
			# 	if match.between? expected, expected+input_leniancy
			# 		# keep going
			# 		if i == inputs.size-1
			# 			# on the final iteration...
			# 			return most_recent_match.last
			# 		end
			# 	else
			# 		# stop immediately
			# 		return nil
			# 	end
			# end
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
end