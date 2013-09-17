#!/usr/bin/env ruby
# encoding: utf-8

Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'
require 'require_all'

require 'state_machine'


require './InputBuffer'

class Window < Gosu::Window
	def initialize
		$window = self
		
		height = 500
		width = 500
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		
		@input_buffer = InputBuffer.new
	end
	
	def needs_cursor?
		true
	end
	
	def update
		
	end
	
	def draw
		translate 50, 50 do
			@input_buffer.draw
		end
	end
	
	def button_down(id)
		close if id == Gosu::KbEscape
		
		case id
			when Gosu::KbReturn
				p @input_buffer
				@input_buffer.reset
			else
				@input_buffer.append(id, :down)
		end
	end
	
	def button_up(id)
		case id
			when Gosu::KbReturn
				
			else
				@input_buffer.append(id, :up)
		end
	end
	
	def shutdown
		
	end
end

x = Window.new
x.show
x.shutdown