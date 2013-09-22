#!/usr/bin/env ruby
# encoding: utf-8

class Window
	def initialize
		@input_buffer = InputBuffer.new
		# inputs go into the buffer, which managed as ring buffer,
		# so that new inputs can go in, and old inputs can be expired easily
		
		
		
		# establish some callbacks, such that when the inputs are detected in the buffer,
		# they can be dealt with
		falling_stab = [Gosu::KbDown, Gosu::KbB]
		
		if @input_buffer.search falling_stab
			# perform some action
		end
		
		
		
		triggers = Array.new # list of triggers such as the example above
		triggers.each do |t|
			if @input_buffer.search t
				# perform action associated with trigger
				
			end
		end
		
		
		# Using a hash like this assumes that all callbacks have unique triggers
		# if the trigger is only the button binding, this is not true
		# each trigger should be unique,
		# but I don't want to have to specify a unique trigger when I create an action
		# triggers need to be reassigned at will
		# triggers should probably be reassiged in some graphical format, 
		# that way I can get more feedback about the system I'm trying to design
		
		actions = Hash.new # trigger => callback
		actions.each do |trigger, callback|
			if @input_buffer.search trigger
				callback.call
			end
		end
		
	end
	
	def update
		@input_buffer.update
		
		
		
		
	end
	
	def button_down(id)
		@input_buffer.button_down id
	end
	
	def button_up(id)
		@input_buffer.button_up id
	end
end