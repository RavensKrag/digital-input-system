# encoding: utf-8

# Manage what strings of inputs to look for,
# what do do when those strings are found,
# and the current state of high-level input.

require 'rubygems'
require 'state_machine'

class Sequence
	include Comparable
	
	CALLBACK_NAMES = [:on_press, :on_hold, :on_release, :on_idle]
	
	NULL_CALLBACK = Proc.new {|o| }
	
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
		
		instance_eval &block
	end
	
	def <=>(other)
		return super(other) unless other.is_a? self.class
		
		@press_events.count <=> other.press_events.count
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
		instance_eval &@callbacks[:on_idle] if enabled?
	end
	
	def hold_callback
		# TODO: give hold duration to the block
		instance_eval &@callbacks[:on_hold] if enabled?
	end
	
	def press_callback
		instance_eval &@callbacks[:on_press] if enabled?
	end
	
	def release_callback
		instance_eval &@callbacks[:on_release] if enabled?
	end
end