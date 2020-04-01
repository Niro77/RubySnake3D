require_relative 'd3object'
require_relative 'utils3_d'

class Entity < D3object
  attr_accessor :objects, :changed
  def initialize
    @objects = []
    @changed = true
    super
  end

  def on_key_hold(key); end

  def inner_update
    @changed = true
    @objects.each do |obj|
      obj.m_base = @world_matrix
      obj.update
    end
  end
end