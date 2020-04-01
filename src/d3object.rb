require_relative 'utils3_d'

class D3object
  attr_reader :f_position_x, :f_position_y, :f_position_z, :f_angle_x, :f_angle_y, :f_angle_z, :m_base
  attr_accessor
  def initialize
    puts "Hi2"
    @f_position_x = 0.0
    @f_position_y = 0.0
    @f_position_z = 0.0
    @m_position = matrix_make_translation(@f_position_x, @f_position_y, @f_position_z)
    @f_angle_x = 0.0
    @m_rotation_x = matrix_make_rotation_x(@f_angle_x)
    @f_angle_y = 0.0
    @m_rotation_y = matrix_make_rotation_y(@f_angle_y)
    @f_angle_z = 0.0
    @m_rotation_z = matrix_make_rotation_z(@f_angle_z)
    @m_base = Matrix.identity(4)
    @world_matrix = @m_base * @m_position * @m_rotation_x * @m_rotation_y * @m_rotation_z
  end

  def m_base=(other)
    @m_base = other
  end

  def f_angle_x=(other)
    @f_angle_x = other
    @m_rotation_x = matrix_make_rotation_x(@f_angle_x)
  end

  def f_angle_y=(other)
    @f_angle_y = other
    @m_rotation_y = matrix_make_rotation_y(@f_angle_y)
  end

  def f_angle_z=(other)
    @f_angle_z = other
    @m_rotation_z = matrix_make_rotation_z(@f_angle_z)
  end

  def set_position(x, y, z)
    @f_position_x = x
    @f_position_y = y
    @f_position_z = z
    reload_transition_matrix
  end

  def f_position_x=(other)
    @f_position_x = other
    reload_transition_matrix
  end

  def f_position_y=(other)
    @f_position_y = other
    reload_transition_matrix
  end

  def f_position_z=(other)
    @f_position_z = other
    reload_transition_matrix
  end

  def reload_transition_matrix
    @m_position = matrix_make_translation(@f_position_x, @f_position_y, @f_position_z)
  end

  def reload_world_matrix
    @world_matrix = @m_base * @m_position * @m_rotation_x * @m_rotation_y * @m_rotation_z
  end

  def update
    puts "update"
    reload_world_matrix
    inner_update
  end

  def inner_update; end
end
