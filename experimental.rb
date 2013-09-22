#!/usr/bin/env ruby
# encoding: utf-8

class Window
	def initialize
		@input_manager = InputManager.new
		
		@input_manager.event :dive_attack do
			bind_to [:down, :b]
			
			
		end
	end
	
	def update
		@input_manager.update
		
		
		
		
	end
	
	def button_down(id)
		@input_manager.button_down id
	end
	
	def button_up(id)
		@input_manager.button_up id
	end
end