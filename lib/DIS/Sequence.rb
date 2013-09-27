# encoding: utf-8

# Manage what strings of inputs to look for,
# what do do when those strings are found,
# and the current state of high-level input.

require 'rubygems'
require 'state_machine'

require 'DIS/Event'

module DIS
	class Sequence
		include Comparable
		
		CALLBACK_NAMES = [:on_press, :on_hold, :on_release, :on_idle]
		
		NULL_CALLBACK = Proc.new {|o| }
		
		# 80ms is considered by some to be the threshold of perception.
		# Specifying this amount of leniency means no leniency at all.
		@@input_leniency = 80
		
		attr_reader :name
		
		def initialize(name, &block)
			super()
			
			@name = name 
			
			# triggers for up and down events
			@press_events = Array.new
			@release_events = Array.new
			
			@callbacks = Hash.new
			CALLBACK_NAMES.each do |name|
				@callbacks[name] = NULL_CALLBACK
			end
			
			instance_eval &block if block
		end
		
		def <=>(other)
			return super(other) unless other.is_a? self.class
			
			self.complexity <=> other.complexity
		end
		
		def complexity
			@press_events.count
		end
		
		#     ____                          ____                  __ 
		#    / __ \____ ______________     /  _/___  ____  __  __/ /_
		#   / /_/ / __ `/ ___/ ___/ _ \    / // __ \/ __ \/ / / / __/
		#  / ____/ /_/ / /  (__  )  __/  _/ // / / / /_/ / /_/ / /_  
		# /_/    \__,_/_/  /____/\___/  /___/_/ /_/ .___/\__,_/\__/  
		#                                        /_/                 
		
		# NOTE: Splitting between up and down like this doesn't work, because some sequences will have ups and down in them.  Use the Event objects instead, like with the buffered input.
		
		def button_down(id)
			# put the button into the buffer
			# check if the buffer is full up and good to go
			
			# press if all press events are fired
			# (AND detection, order dependent)
			
			@press_i ||= 0
			
			if id == @press_events[@press_i]
				# part of sequence detected
				@press_i += 1
			end
			
			if @press_i == @press_events.size
				# sequence completed
				
			end
		end
		
		def button_up(id)
			# deal with button releases
			# NOTE: algorithm will need to check on button down as well, if cancels are allowed
			
			# release if any of the release events has fired
			# (OR detection)
			
			if @release_events.include? id
				@press_i = 0
			end
		end
		
		
		
		
		
		def add(event)
			# events signal either button up or button down inputs
			
			press if trigger_press? event
			release if trigger_release? event
		end
		
		def trigger_press?(event)
			@press_i ||= 0
			
			
			# events match up if
			# all of the following (AND detection)
			# * the input signal for the actual event matches the expected exactly
			# * the time of the actual event is close enough to the expected time
			
			
			
			# event.timestamp.between? expected_event.timestamp, expected_event.timestamp+dt
			# => timestamp < event.timestamp < timestamp + dt
			
			# timestamp - event.timestamp < dt
			# * bounded on the bottom, but not the top
			# * bounded by start time, but not by end
			
			
			
			
			
			
			# put the button into the buffer
			# check if the buffer is full up and good to go
			
			# press if all press events are fired
			# (AND detection, order dependent)
			
			# See if the incoming event matches against this particular input sequence
			# if event == @press_events[@press_i] # probably can't match with equality test
			expected = @press_events[@press_i]
			if expected.input == event.input
				# desired input
				
				
				# expected timestamps are given relative to the time of the first event
				# runtime timestamps need to be adjusted accordingly
				if event_within_acceptable_time_threshold?(event, expected)
					# acceptable time
					
					# proceed
					
					# part of sequence detected
					@press_i += 1
				else
					# not within the time window
					
					reset_search
				end
			else
				# not the desired input
			end
			
			if @press_i == @press_events.size
				# sequence completed
				
				# fire event
				# start looking from the beginning again
				reset_search
				
				return true
			end
			
			
			return false
		end
		
		def trigger_release?(event)
			# deal with button releases
			# NOTE: algorithm will need to check on button down as well, if cancels are allowed
			
			# release if any of the release events has fired
			# (OR detection)
			p @release_events
			
			if @release_events.include? event
				reset_search
				
				puts "========RELEASE"
				
				return true
			end
			
			
			return false
		end
		
		def reset_search
			@press_i ||= 0
			
			@press_i = 0
		end
		
		
		# this is the trickiest part of the algorithm
		# it may take allocation of data which is not necessary elsewhere,
		# if possible, I would like to contain it here
		# because the rest of the code flow is pretty clean
		def event_within_acceptable_time_threshold?(event, expected)
			if @press_i == 0
				# first event detected
				# check if the first event is timely
				
				# first event doesn't matter
				# use this to establish the time basis
				@time_basis = event.timestamp
			end
			
			
			time = event.timestamp - @time_basis
			
			time.between? expected.timestamp, expected.timestamp+@@input_leniency
		end
		
		
		#     ______                 __     __    _      __ 
		#    / ____/   _____  ____  / /_   / /   (_)____/ /_
		#   / __/ | | / / _ \/ __ \/ __/  / /   / / ___/ __/
		#  / /___ | |/ /  __/ / / / /_   / /___/ (__  ) /_  
		# /_____/ |___/\___/_/ /_/\__/  /_____/_/____/\__/  
		
		attr_accessor :press_events, :release_events
		
		
		#    ______      ______               __       
		#   / ____/___ _/ / / /_  ____ ______/ /_______
		#  / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
		# / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
		# \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
		# Definition only.  Execution is only ever handled internally
		
		CALLBACK_NAMES.each do |callback_name|
			define_method callback_name do |&block|
				@callbacks[callback_name] = block
			end
			private callback_name
		end
		
		
		#    _____ __        __     
		#   / ___// /_____ _/ /____ 
		#   \__ \/ __/ __ `/ __/ _ \
		#  ___/ / /_/ /_/ / /_/  __/
		# /____/\__/\__,_/\__/\___/ 
		# (Contains update)
		
		state_machine :status, :initial => :idle do
			state :idle do
				def update
					idle_callback
				end
			end
			
			state :active do
				def update
					hold_callback
				end
			end
			
			
			event :press do
				transition :idle => :active
			end
			
			event :release do
				transition :active => :idle
			end
			
			
			after_transition :idle => :active, :do => :press_callback
			after_transition :active => :idle, :do => :release_callback
		end
		
		private
		
		# [:press, :hold, :release, :idle].each do |event|
		# 	define_method "#{event}_callback" do
		# 		instance_eval &@callbacks["on_#{event}".to_sym] if enabled?
		# 	end
		# end
		
		
		def idle_callback
			instance_eval &@callbacks[:on_idle]
		end
		
		def hold_callback
			# TODO: give hold duration to the block
			instance_eval &@callbacks[:on_hold]
		end
		
		def press_callback
			puts "press"
			instance_eval &@callbacks[:on_press]
		end
		
		def release_callback
			instance_eval &@callbacks[:on_release]
		end
	end
end