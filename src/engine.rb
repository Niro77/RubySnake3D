require_relative 'utils3_d'
include Math

class MyEngine
  attr_accessor :f_yaw, :v_camera, :output
  def initialize(screen_h, screen_w)
    @f_yaw = 0
    @f_theta = 0
    @screen_h = screen_h
    @screen_w = screen_w
    @f_elapsed_time = 0
    # Rotation Z
    @mat_rot_z = matrix_make_rotation_z(@f_theta)
    # Rotation X
    @mat_camera_rot = matrix_make_rotation_y(@f_yaw)
    @mat_rot_x = matrix_make_rotation_x(@f_theta)
    @plane_p = new_vec3(0.0, 0.0, 0.1)
    @plane_n = new_vec3(0.0, 0.0, 1.0)
    @v_up = new_vec3(0.0, 1.0, 0.0)
    @v_look_dir = new_vec3(0.0, 0.0, 0.0)
    @v_camera = new_vec3(0.0, 0.0, 0.0)
    @v_target = new_vec3(0.0, 0.0, 1.0, 1.0)
    @mat_trans = matrix_make_translation(0.0, 0.0, 8.0)
    @light_direction = new_vec3(0.0, 0.0, -1.0).normalize
    @mat_world = @mat_rot_x * @mat_rot_z
    @mat_world *= @mat_trans

    @planes = [[new_vec3(0.0, 0.0, 0.0), new_vec3(0.0, 1.0, 0.0)],
               [new_vec3(0.0, screen_h.to_f - 1.0, 0.0), new_vec3(0.0, -1.0, 0.0)],
               [new_vec3(0.0, 0.0, 0.0), new_vec3(1.0, 0.0, 0.0)],
               [new_vec3(screen_w.to_f - 1.0, 0.0, 0.0), new_vec3(-1.0, 0.0, 0.0)]]


    @mesh_cube = Mesh.from_file('.\\objects\\axis.obj')
    # @mesh_cube = Mesh.from_file('.\\objects\\mountains.obj')
    f_near = 0.1
    f_far = 1000.0
    f_fov = 90.0
    f_aspect_ratio = screen_h.to_f / screen_w
    @mat_proj = matrix_make_projection(f_near, f_far, f_fov, f_aspect_ratio)
    @output = []
  end

  def project_triangle(tri_view)
    output = []
    triangle_clip_plane(@plane_p, @plane_n, tri_view).each do |new_tri|
      tri_proj = new_tri.mult_by_matrix!(@mat_proj)
      tri_proj.color = tri_view.color
      tri_proj.normalize

      tri_proj.vecs[0][0] += 1.0
      tri_proj.vecs[0][1] += 1.0
      tri_proj.vecs[1][0] += 1.0
      tri_proj.vecs[1][1] += 1.0
      tri_proj.vecs[2][0] += 1.0
      tri_proj.vecs[2][1] += 1.0
      tri_proj.vecs[0][0] *= 0.5 * @screen_w
      tri_proj.vecs[0][1] *= 0.5 * @screen_h
      tri_proj.vecs[1][0] *= 0.5 * @screen_w
      tri_proj.vecs[1][1] *= 0.5 * @screen_h
      tri_proj.vecs[2][0] *= 0.5 * @screen_w
      tri_proj.vecs[2][1] *= 0.5 * @screen_h
      output.push(tri_proj)
    end
    output
  end

  def intersect(output, tri_to_raster)
    until tri_to_raster.empty?
      tri = tri_to_raster.pop
      process_list = [tri]
      @planes.each do |plane|
        temp = []
        until process_list.empty?
          test = process_list.pop
          temp.push(*triangle_clip_plane(plane[0], plane[1], test))
        end
        process_list = temp
      end
      output.push(*process_list)
    end
  end

  def re_draw(entity)
    entity.objects.each do |obj|
      @v_look_dir = @mat_camera_rot * @v_target
      v_target2 = @v_camera + @v_look_dir
      mat_camera = matrix_make_point_at(@v_camera, v_target2, @v_up)
      mat_view = matrix_quick_inverse(mat_camera)
      #mat_view = mat_camera.inverse

      tri_to_raster = []
      obj.translate_mesh.tris.each do |tri|
        tri_trans = tri.mult_by_matrix(@mat_world)
        normal = tri_trans.normal
        v_camera_ray = tri_trans.vecs[0] - @v_camera
        next unless normal.dot(v_camera_ray) < 0.0
        # Project
        tri_view = tri_trans.mult_by_matrix(mat_view)
        tri_view.color = normal.dot(@light_direction)

        tri_to_raster.push(*project_triangle(tri_view))
      end

      obj.view_mesh.tris = []
      intersect(obj.view_mesh.tris, tri_to_raster)
    end
  end

  def get_buffer(entities)
    output = []
    entities.each do |entity|
      entity.objects.each do |obj|
        obj.view_mesh.tris.each { |tri| output.push(tri) }
      end
    end
    output.sort { |a, b| b.calc_z <=> a.calc_z }
  end

  def key_held(key)
    v_forward = @v_look_dir * (8.0 * @f_elapsed_time)
    case key
    when 'up'
      @v_camera[1] += 8.0 * @f_elapsed_time
    when 'down'
      @v_camera[1] -= 8.0 * @f_elapsed_time
    when 'a'
      @f_yaw += 2.0 * @f_elapsed_time
      @mat_camera_rot = matrix_make_rotation_y(@f_yaw)
    when 'd'
      @f_yaw -= 2.0 * @f_elapsed_time
      @mat_camera_rot = matrix_make_rotation_y(@f_yaw)
    when 'w'
      @v_camera = @v_camera + v_forward
    when 's'
      @v_camera = @v_camera - v_forward
    end
  end
end





# Projection Matrix