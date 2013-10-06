# encoding: utf-8

# Manage what strings of inputs to look for,
# what do do when those strings are found,
# and the current state of high-level input.

# require 'rubygems'
require 'state_machine'

# require './DIS/Event'

module DIS
	class Sequence
		include Comparable
		
		# 80ms is considered by some to be the threshold of perception.
		# Specifying this amount of leniency means no leniency at all.
		@@input_leniency = 80
		
		attr_reader :name
		
		def initialize(name)
			super()
			
			@name = name 
			
			# triggers for up and down events
			@press_events = Array.new
			@release_events = Array.new
			
			
			# callbacks to be fired on events
			@callbacks = CallbackManager.new
		end
		
		def <=>(other)
			# return super(other) unless other.is_a? self.class # FIXME: this seems cause problems
			
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
			
			if @release_events.include? event
				reset_search
				
				return true
			end
			
			
			return false
		end
		
		def reset_search
			@press_i = 0
		end
		
		
		# this is the trickiest part of the algorithm
		# it may take allocation of data which is not necessary elsewhere,
		# if possible, I would like to contain it here
		# because the rest of the code flow is pretty clean
		# TODO: Rename to something shorter (maybe #recent?)
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
		
		
		#    _____ __        __     
		#   / ___// /_____ _/ /____ 
		#   \__ \/ __/ __ `/ __/ _ \
		#  ___/ / /_/ /_/ / /_/  __/
		# /____/\__/\__,_/\__/\___/ 
		# (Contains update)
		
		state_machine :button_state, :initial => :idle do
			state :idle do
				def update
					@callbacks.idle
				end
			end
			
			state :going_down do
				def update
					@callbacks.press
					
					# transition to :active
					to_active
				end
			end
			
			state :active do
				def update
					@callbacks.hold
				end
			end
			
			state :going_up do
				def update
					@callbacks.release
					
					# transition to :idle
					to_idle
				end
			end
			
			
			event :press do
				transition :idle => :going_down
			end
			
			event :to_active do
				transition :going_down => :active
			end
			
			event :release do
				transition :active => :going_up
			end
			
			event :to_idle do
				transition :going_up => :idle
			end
			
			event :cancel_event do
				transition any => :idle
			end
			# make sure that reset not called on transition from :idle to :idle
			# (it shouldn't have any effect, but it's kinda wasteful / annoying)
		end
		# private :to_idle, :to_active
		private :cancel_event
		
		# define cancels this way to allow execution of callback on event, rather than transition
		def cancel
			cancel_event
			reset_search
			@callbacks.cancel
		end
		
		def positive?
			return going_down? || active?
		end
		
		def negative?
			return going_up? || idle?
		end
		
		
		#    ______      ______               __       
		#   / ____/___ _/ / / /_  ____ ______/ /_______
		#  / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
		# / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
		# \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
		# Definition only.  Execution is only ever handled internally
		
		attr_reader :callbacks
		
		
		private
		
		
		# Multiple sets of callbacks can be bound to one sequence
		# this class organizes those callback sets
		# (disambiguation must be handled outside of this input parsing framework)
		class CallbackManager
			# NOTE: It is possible to force all callbacks to execute from outside of the input framework.  This may be problematic.
			
			# NOTE: Currently, all callbacks must be defined at once.  Attempting to define a second callback set with the same name will override the first set.
			
			CALLBACK_NAMES = [:press, :hold, :release, :idle, :cancel]
			
			
			def initialize
				@callbacks = Hash.new # name => set of callbacks
			end
			
			def [](name)
				# return a callback set associated with the given name
				# create a new set if no set is currently established
				
				@callbacks[name] = CallbackSet.new unless @callbacks[name]
				
				return @callbacks[name]
			end
			
			def delete(name)
				@callbacks.delete name
			end
			
			def include?(name)
				@callbacks.include?(name)
			end
			
			def clear
				@callbacks.clear
			end
			
			
			# Run all stored callbacks
			CALLBACK_NAMES.each do |type|
				
				define_method type do
					@callbacks.each do |name, callback_set|
						callback_set.send "#{type}_callback"
					end
				end
				
			end
			
			
			private
			
			# sets of callbacks should not be definable outside of the provided interface
			# although, the methods of the collection itself should be public,
			# so that the collection can be further altered after initial creation
			
			
			
			# Hold one set of callbacks
			class CallbackSet
				# TODO: Consider using a bunch of instance variables instead of a hash
				# don't really need the full capabilities of a hash
				
				def initialize
					@callbacks = Hash.new
				end
				
				
				# because of the instance eval,
				# the callback is bound to the execution scope of the instance_eval,
				# which is this object
				# so even if the callback is executed without instance_eval,
				# it will still have this object as it's execution scope
				# 
				# this is not the desired behavior
				# 
				# the callback should execute within the scope of the object where it was defined
				
				
				CALLBACK_NAMES.each do |event|
					# ===== callback definition ===== 
					define_method "on_#{event}" do |&block|
						@callbacks[event] = block
					end
					# private callback_name
					
					
					# =====  callback execution ===== 
					define_method "#{event}_callback" do |&block|
						@callbacks[event].call if @callbacks[event]
					end
				end
			end
		end
	end
end