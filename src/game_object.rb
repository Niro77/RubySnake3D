require_relative 'd3object'
require_relative 'utils3_d'

class GameObject < D3object
  attr_accessor :translate_mesh, :view_mesh, :mesh
  def initialize
    @mesh = Mesh.new([])
    @translate_mesh = Mesh.new([])
    @view_mesh = Mesh.new([])
    super
  end

  def inner_update
    @translate_mesh = Mesh.new(@mesh.tris.map { |tri| tri.mult_by_matrix(@world_matrix) })
  end
end