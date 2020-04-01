require 'matrix'
include Math

def new_vec3(*vals)
  if vals.length == 3
    Vector[vals[0], vals[1], vals[2], 1.0]
  else
    Vector[*vals]
  end
end
# Triangle
class MyTriangle
  attr_accessor :vecs, :color
  def initialize(*vecs)
    @vecs = vecs.length == 3 ? vecs : [new_vec3(0.0, 0.0, 0.0), new_vec3(0.0, 0.0, 0.0), new_vec3(0.0, 0.0, 0.0)]
    @color = 0
    @render_memory = []
  end

  def normalize
    new_vecs = []
    @vecs.each do |vec|
      tmp = vec / vec[3]
      tmp[0] = tmp[0] * -1.0
      tmp[1] = tmp[1] * -1.0
      new_vecs.push(tmp)
    end
    @vecs = new_vecs
  end

  def normal
    # line1 = new_vec3(@vecs[1][0] - @vecs[0][0],
    #                  @vecs[1][1] - @vecs[0][1],
    #                  @vecs[1][2] - @vecs[0][2])
    # line2 = new_vec3(@vecs[2][0] - @vecs[0][0],
    #                  @vecs[2][1] - @vecs[0][1],
    #                  @vecs[2][2] - @vecs[0][2])
    l10 = @vecs[1][0] - @vecs[0][0]
    l11 = @vecs[1][1] - @vecs[0][1]
    l12 = @vecs[1][2] - @vecs[0][2]
    l20 = @vecs[2][0] - @vecs[0][0]
    l21 = @vecs[2][1] - @vecs[0][1]
    l22 = @vecs[2][2] - @vecs[0][2]
    a = l11 * l22 - l12 * l21
    b = l12 * l20 - l10 * l22
    c = l10 * l21 - l11 * l20
    norm = new_vec3(a, b, c)

    # It's normally normal to normalise the normal
    if norm.zero?
      return norm
    end
    norm.normalize

  end

  def to_2d_full_tri
    Triangle.new(x1: @vecs[0][0], y1: @vecs[0][1],
                 x2: @vecs[1][0], y2: @vecs[1][1],
                 x3: @vecs[2][0], y3: @vecs[2][1],
                 color: [@color, @color, @color, 1.0])
  end

  def to_2d_outline_tri
    shapes = []
    color = 'white'
    shapes.push(Line.new(x1: @vecs[0][0], y1: @vecs[0][1],
                         x2: @vecs[1][0], y2: @vecs[1][1],
                         width: 2,
                         color: color))
    shapes.push(Line.new(x1: @vecs[1][0], y1: @vecs[1][1],
                         x2: @vecs[2][0], y2: @vecs[2][1],
                         width: 2,
                         color: color))
    shapes.push(Line.new(x1: @vecs[2][0], y1: @vecs[2][1],
                         x2: @vecs[0][0], y2: @vecs[0][1],
                         width: 2,
                         color: color))
    shapes
  end

  def mult_by_matrix(matrix)
    MyTriangle.new(multiply_matrix4_vector3(@vecs[0], matrix),
                   multiply_matrix4_vector3(@vecs[1], matrix),
                   multiply_matrix4_vector3(@vecs[2], matrix))
  end

  def mult_by_matrix!(matrix)
    @vecs[0] = multiply_matrix4_vector3!(@vecs[0], matrix)
    @vecs[1] = multiply_matrix4_vector3!(@vecs[1], matrix)
    @vecs[2] = multiply_matrix4_vector3!(@vecs[2], matrix)
    self
  end

  def calc_z
    (@vecs[0][2] + @vecs[1][2] + @vecs[2][2]) / 3.0
  end

  def to_s
    "MyTriangle: #{vecs[0]}, #{@vecs[1]}, #{@vecs[2]}"
  end
end

# Mesh
class Mesh
  attr_accessor :tris
  def initialize(triangles)
    @tris = triangles
  end

  def Mesh.from_file(f_name)
    tris = []
    vector_list = []
    File.foreach(f_name) do |line|
      parts = line.split(' ')
      case parts[0]
      when 'v'
        vector_list.push(new_vec3(parts[1].to_f, parts[2].to_f, parts[3].to_f))
      when 'f'
        tris.push(MyTriangle.new(vector_list[parts[1].to_i - 1],
                                 vector_list[parts[2].to_i - 1],
                                 vector_list[parts[3].to_i - 1]))
      end
    end
    new tris
  end
end

# Functions
def multiply_matrix4_vector3!(i, m)
  x = i[0] * m[0, 0] + i[1] * m[1, 0] + i[2] * m[2, 0] + i[3] * m[3, 0]
  y = i[0] * m[0, 1] + i[1] * m[1, 1] + i[2] * m[2, 1] + i[3] * m[3, 1]
  z = i[0] * m[0, 2] + i[1] * m[1, 2] + i[2] * m[2, 2] + i[3] * m[3, 2]
  w = i[0] * m[0, 3] + i[1] * m[1, 3] + i[2] * m[2, 3] + i[3] * m[3, 3]
  i[0] = x
  i[1] = y
  i[2] = z
  i[3] = w
  i
  # b = i.covector * m
  # b.row(0)
end
def multiply_matrix4_vector3(i, m)
  x = i[0] * m[0, 0] + i[1] * m[1, 0] + i[2] * m[2, 0] + i[3] * m[3, 0]
  y = i[0] * m[0, 1] + i[1] * m[1, 1] + i[2] * m[2, 1] + i[3] * m[3, 1]
  z = i[0] * m[0, 2] + i[1] * m[1, 2] + i[2] * m[2, 2] + i[3] * m[3, 2]
  w = i[0] * m[0, 3] + i[1] * m[1, 3] + i[2] * m[2, 3] + i[3] * m[3, 3]
  Vector[x, y, z, w]
  # b = i.covector * m
  # b.row(0)
end

def vector_cross(v1, v2)
  new_vec3(v1[1] * v2[2] - v1[2] * v2[1],
           v1[2] * v2[0] - v1[0] * v2[2],
           v1[0] * v2[1] - v1[1] * v2[0])
end

def matrix_make_rotation_x(angle_rad)
  Matrix[[1, 0, 0, 0],
         [0, cos(angle_rad), sin(angle_rad), 0],
         [0, -sin(angle_rad), cos(angle_rad), 0],
         [0, 0, 0, 1]]
end

def matrix_make_rotation_y(angle_rad)
  Matrix[[cos(angle_rad), 0, sin(angle_rad), 0],
         [0, 1, 0, 0],
         [-sin(angle_rad), 0, cos(angle_rad), 0],
         [0, 0, 0, 1]]
end

def matrix_make_rotation_z(angle_rad)
  Matrix[[cos(angle_rad), sin(angle_rad), 0, 0],
         [-sin(angle_rad), cos(angle_rad), 0, 0],
         [0, 0, 1, 0],
         [0, 0, 0, 1]]
end

def matrix_make_translation(x, y, z)
  m = Matrix.identity(4)
  m[3, 0] = x
  m[3, 1] = y
  m[3, 2] = z
  m
end

def matrix_make_projection(f_near, f_far, f_fov, f_aspect_ratio)
  f_fov_rad = 1.0 / tan(f_fov * 0.5 / 180.0 * 3.14159)
  Matrix[[f_aspect_ratio * f_fov_rad, 0, 0, 0],
         [0, f_fov_rad, 0, 0],
         [0, 0, f_far / (f_far - f_near), 1.0],
         [0, 0, (-f_far * f_near) / (f_far - f_near), 0]]
end

def matrix_make_point_at(pos, target, up)
  new_forward = (target - pos).normalize
  new_up = (up - (new_forward * up.dot(new_forward))).normalize
  new_right = vector_cross(new_up, new_forward)
  Matrix[[new_right[0], new_right[1], new_right[2], 0.0],
         [new_up[0], new_up[1], new_up[2], 0.0],
         [new_forward[0], new_forward[1], new_forward[2], 0.0],
         [pos[0], pos[1], pos[2], 1.0]]
end

def matrix_quick_inverse(in_mat)
  m30 = -(in_mat[3, 0] * in_mat[0, 0] + in_mat[3, 1] * in_mat[0, 1] + in_mat[3, 2] * in_mat[0, 2])
  m31 = -(in_mat[3, 0] * in_mat[1, 0] + in_mat[3, 1] * in_mat[1, 1] + in_mat[3, 2] * in_mat[2, 1])
  m32 = -(in_mat[3, 0] * in_mat[2, 0] + in_mat[3, 1] * in_mat[2, 1] + in_mat[3, 2] * in_mat[2, 2])
  Matrix[[in_mat[0, 0], in_mat[1, 0], in_mat[2, 0], 0.0],
         [in_mat[0, 1], in_mat[1, 1], in_mat[2, 1], 0.0],
         [in_mat[0, 2], in_mat[1, 2], in_mat[2, 2], 0.0],
         [m30, m31, m32, 1.0]]
end

def vector_intersect_plane(plane_p, plane_n, line_start, line_end)
  plane_d = - plane_n.dot(plane_p)
  ad = line_start.dot(plane_n)
  t = (-plane_d - ad) / (line_end.dot(plane_n) - ad)
  line_start + ((line_end - line_start) * t)
end

def dist_vec_plane(vec, plane_n, plane_p)
  plane_n[0] * vec[0] + plane_n[1] * vec[1] + plane_n[2] * vec[2] - plane_n.dot(plane_p)
end

def triangle_clip_plane(plane_p, plane_n, tri)
  plane_n = plane_n.normalize
  inside_points = []
  outside_points = []

  tri.vecs.each do |vec|
    if dist_vec_plane(vec, plane_n, plane_p) >= 0
      inside_points.push(vec)
    else
      outside_points.push(vec)
    end
  end

  case inside_points.length
  when 3
    [tri]
  when 1
    tri.vecs[0] = inside_points[0]
    tri.vecs[1] = vector_intersect_plane(plane_p, plane_n, inside_points[0], outside_points[0])
    tri.vecs[2] = vector_intersect_plane(plane_p, plane_n, inside_points[0], outside_points[1])
    [tri]
  when 2
    temp = vector_intersect_plane(plane_p, plane_n, inside_points[0], outside_points[0])
    [MyTriangle.new(inside_points[0], inside_points[1], temp),
     MyTriangle.new(inside_points[1], temp,
                    vector_intersect_plane(plane_p, plane_n, inside_points[1], outside_points[0]))]
  else
    []
  end

end
