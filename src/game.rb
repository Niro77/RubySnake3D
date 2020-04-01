require_relative 'engine'
require_relative 'game_object'
require_relative 'entity'
require_relative 'snake'

class Game
  attr_accessor :engine
  def initialize(height, width, window)
    @game_window = window
    @engine = MyEngine.new(height, width)
    snake = Snake.new
    @entities = [snake] # Ha enTITIES
    #@game_window.on(:key_held) { |event| on_key_hold(event.key) }
    @game_window.on(:key_down) { |event| snake.on_key_down(event.key) }
    @timed_events = {}
    on_time(snake.tick_every) { || snake.move }
  end

  def on_time(time, &proc)
    @timed_events[time] = [proc, time]
  end

  def game_loop
    time = Time.now - @start
    @start = Time.now
    @timed_events.each do |key, value|
      value[1] -= time
      if value[1].negative?
        value[0].call
        value[1] = key
      end
      
    end
    logic
    draw
      #puts "#{time} #{@game_window.fps}"
  end

  def logic
  end

  def on_key_hold(key)
    @entities.each { |entity| entity.on_key_hold(key)}
  end

  def draw
    @game_window.clear
    shapes = []
    @entities.each do |entity|
      if entity.changed
        puts "entity changed: #{entity}"
        @engine.re_draw(entity)
        entity.changed = false
      end
    end
    engine.get_buffer(@entities).each do |tri|
      shapes.push(*tri.to_2d_outline_tri)
      # shapes.push(tri.to_2d_full_tri)
    end
  end

  def run
    @start = Time.now
    @game_window.update do game_loop end
    @game_window.show
  end

end