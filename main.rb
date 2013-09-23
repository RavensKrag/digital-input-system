#!/usr/bin/env ruby
# encoding: utf-8

Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'
require 'require_all'

require 'state_machine'

require './InputManager'
require './InputBuffer'
	require './RingBuffer'
require './Sequence'
require './Event'
require './Input'

class Window < Gosu::Window
	def initialize
		$window = self
		
		height = 800
		width = 800
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		
		@inpman = InputManager.new
		
		sequence = Sequence.new :test do
			on_press do
				
			end
			
			on_hold do
				
			end
			
			on_release do
				
			end
			
			on_idle do
				
			end
		end
		sequence.press_events = [
			Event.new(Gosu::KbA, :down,	0+300*0),
			Event.new(Gosu::KbA, :up,	200+300*0),
			
			Event.new(Gosu::KbO, :down,	0+300*1),
			Event.new(Gosu::KbO, :up,	200+300*1),
			
			Event.new(Gosu::KbE, :down,	0+300*2)
		]

		# release event timestamps are irrelevant
		# release event fire when any one of the release events are detected
		sequence.release_events = [
			Event.new(Gosu::KbE, :up,	0)
		]


	end
	
	def needs_cursor?
		true
	end
	
	def update
		@inpman.update
	end
	
	def draw
		translate 50, 50 do
			# @input_buffer.draw
		end
	end
	
	def button_down(id)
		close if id == Gosu::KbEscape
		
		case id
			when Gosu::KbReturn
				@inpman.reset
			else
				@inpman.button_down id
		end
	end
	
	def button_up(id)
		case id
			when Gosu::KbReturn
				
			else
				@inpman.button_up id
		end
	end
	
	def shutdown
		
	end
end

x = Window.new
x.show
x.shutdown