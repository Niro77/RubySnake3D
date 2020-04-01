require_relative 'entity'

class Snake < Entity
  attr_reader :tick_every
  def initialize
    super
    @body_mesh = Mesh.from_file('.\\objects\\cube.obj')
    @objects = [create_body_part]
    @tick_every = 1
    @direction = new_vec3(0.0, 1.0, 0.0)
    @length = 6
    update
  end

  def head
    @objects[0]
  end

  def create_body_part
    obj = GameObject.new
    obj.mesh = @body_mesh
    obj
  end

  def move
    speed = 1
    h = head
    new_body = create_body_part
    new_body.set_position(h.f_position_x, h.f_position_y, h.f_position_z)
    @objects.insert(1, new_body)
    if @objects.length > @length
      @objects.pop
    end
    h.set_position(h.f_position_x + @direction[0],
                   h.f_position_y + @direction[1],
                   h.f_position_z + @direction[2])
    new_body.update
    h.update
    @changed = true
  end

  def on_key_down(key)
    case key
    when 'd'
      @direction = multiply_matrix4_vector3(@direction, Matrix[[0, 1, 0, 0],
                                                               [-1, 0, 0, 0],
                                                               [0, 0, 1, 0],
                                                               [0, 0, 0, 1]])
    when 'a'
      @direction = multiply_matrix4_vector3(@direction, Matrix[[0, -1, 0, 0],
                                                               [1, 0, 0, 0],
                                                               [0, 0, 1, 0],
                                                               [0, 0, 0, 1]])
    when 'w'
      @direction = multiply_matrix4_vector3(@direction, Matrix[[0, 0, 1, 0],
                                                               [0, 1, 0, 0],
                                                               [-1, 0, 0, 0],
                                                               [0, 0, 0, 1]])
    when 's'
      @direction = multiply_matrix4_vector3(@direction, Matrix[[0, 0, -1, 0],
                                                               [0, 1, 0, 0],
                                                               [1, 0, 0, 0],
                                                               [0, 0, 0, 1]])

    end
  end

  def on_key_hold(key)
    case key
    when 'up'
      self.f_position_y = @f_position_y + 0.2
      update
    when 'down'
      self.f_position_y = @f_position_y - 0.2
      update
    when 'a'
      self.f_position_x = @f_position_x + 0.2
      update
    when 'd'
      self.f_position_x = @f_position_x - 0.2
      update
    when 'w'
      self.f_position_z = @f_position_z + 0.2
      update
    when 's'
      self.f_position_z = @f_position_z - 0.2
      update
    end
  end
end