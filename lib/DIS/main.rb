#!/usr/bin/env ruby
# encoding: utf-8

Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'
require 'require_all'

require 'state_machine'

require '../DIS'
require './InputManager'
require './InputBuffer'
	require './RingBuffer'
require './Sequence'
require './Event'
require './Input'

module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end

class Window < Gosu::Window
	def initialize
		$window = self
		
		height = 800
		width = 800
		fullscreen = false
		
		update_interval = 1/60.0*1000
		
		super(width, height, fullscreen, update_interval)
		
		@debug_font = Gosu::Font.new self, "Lucida Sans Unicode", 20
		
		
		
		@inpman = DIS::InputManager.new
		
		single = DIS::Sequence.new :single do
			on_press do
				puts "SINGLE BUTTON #{Gosu::milliseconds}"
			end
			
			on_hold do
				puts "SINGLE BUTTON #{Gosu::milliseconds}"
			end
			
			on_release do
				puts "it's dangerous to go alone"
			end
			
			on_idle do
				
			end
		end
		single.press_events = [
			DIS::Event.new(Gosu::KbD, :down, 0)
		]

		# release event timestamps are irrelevant
		# release event fire when any one of the release events are detected
		single.release_events = [
			DIS::Event.new(Gosu::KbD, :up, 0)
		]
		
		
		
		
		sequence = DIS::Sequence.new :sequence do
			on_press do
				puts "BUTTON DOWN"
			end
			
			on_hold do
				
			end
			
			on_release do
				
			end
			
			on_idle do
				
			end
		end
		sequence.press_events = [
			DIS::Event.new(Gosu::KbA, :down,	0+300*0),
			DIS::Event.new(Gosu::KbA, :up,	200+300*0),
			
			DIS::Event.new(Gosu::KbS, :down,	0+300*1),
			DIS::Event.new(Gosu::KbS, :up,	200+300*1),
			
			DIS::Event.new(Gosu::KbD, :down,	0+300*2)
		]

		# release event timestamps are irrelevant
		# release event fire when any one of the release events are detected
		sequence.release_events = [
			DIS::Event.new(Gosu::KbD, :up,	0)
		]
		
		
		# ERROR: false negative on reverse roll -> chord
		# ex) roll(c,b,a) -> chord(a,b,c) -> chord(a,b,c)
		# 		first chord not detected, but second chord is
		chord = DIS::Sequence.new :chord do
			on_press do
				puts "GOGOGOG!!!! #{Gosu::milliseconds}"
			end
			
			on_hold do
				puts "GOGOGOG!!!! #{Gosu::milliseconds}"
			end
			
			on_release do
				puts "OUTTA HERE D:"
			end
			
			on_idle do
				# puts "GOGOGOG!!!!"
			end
		end
		chord.press_events = [
			DIS::Event.new(Gosu::KbA, :down,	0),
			DIS::Event.new(Gosu::KbS, :down,	0),
			DIS::Event.new(Gosu::KbD, :down,	0)
		]

		# release event timestamps are irrelevant
		# release event fire when any one of the release events are detected
		chord.release_events = [
			DIS::Event.new(Gosu::KbA, :up,	0),
			DIS::Event.new(Gosu::KbS, :up,	0),
			DIS::Event.new(Gosu::KbD, :up,	0)
		]
		
		
		
		mouse_and_keyboard = DIS::Sequence.new :mouse_and_keyboard do
			on_press do
				puts "----CLICK #{Gosu::milliseconds}"
			end
			
			on_hold do
				puts "----CLICK #{Gosu::milliseconds}"
			end
			
			on_release do
				puts "nope nope nope"
			end
			
			on_idle do
				# puts "GOGOGOG!!!!"
			end
		end
		mouse_and_keyboard.press_events = [
			DIS::Event.new(Gosu::MsLeft, :down, 0),
			DIS::Event.new(Gosu::KbLeftShift, :down, 0)
		]
		
		mouse_and_keyboard.release_events = [
			DIS::Event.new(Gosu::MsLeft, :up, 0),
			# DIS::Event.new(Gosu::KbLeftShift, :up, 0)
		]
		
		
		# @inpman.add sequence
		@inpman.add chord
		@inpman.add single
		@inpman.add mouse_and_keyboard
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
		
		@debug_font.draw Gosu.fps, 0,0, 1000
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