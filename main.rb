# frozen_string_literal: true
require_relative 'src/game'
require 'ruby2d'

set title: 'Hello Not Triangle'
game = Game.new((get :height), (get :width), Window)
start = Time.now

on :key_held do |event|
  game.engine.key_held(event.key)
end


game.run