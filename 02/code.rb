# frozen_string_literal: true

require 'opengl'
require 'glfw'
require 'matrix'

def compile_shader(type, source)
  shader = GL.CreateShader(type)
  GL.ShaderSource(shader, 1, [source].pack('p'), [source.bytesize].pack('I'))
  GL.CompileShader(shader)

  status_buf = ' ' * 4
  status = GL.GetShaderiv(shader, GL::COMPILE_STATUS, status_buf)
  if status == GL::FALSE
    log = GL.GetShaderInfoLog(shader)
    raise "Shader compile error: #{log}"
  end

  shader
end

def create_shader_program(vertex_source, fragment_source)
  vertex_shader = compile_shader(GL::VERTEX_SHADER, vertex_source)
  fragment_shader = compile_shader(GL::FRAGMENT_SHADER, fragment_source)

  program = GL.CreateProgram()
  GL.AttachShader(program, vertex_shader)
  GL.AttachShader(program, fragment_shader)
  GL.LinkProgram(program)

  status_buf = ' ' * 4
  status = GL.GetProgramiv(program, GL::LINK_STATUS, status_buf)
  if status == GL::FALSE
    log = GL.GetProgramInfoLog(program)
    raise "Program link error: #{log}"
  end

  GL.DeleteShader(vertex_shader)
  GL.DeleteShader(fragment_shader)

  program
end

def create_cube_vertices
  vertices = [
    # Front face
    -0.5, -0.5, 0.5, 1.0, 0.0, 0.0,
    0.5, -0.5,  0.5,  1.0, 0.0, 0.0,
    0.5,  0.5,  0.5,  1.0, 0.0, 0.0,
    -0.5,  0.5,  0.5,  1.0, 0.0, 0.0,

    # Back face
    -0.5, -0.5, -0.5,  0.0, 1.0, 0.0,
    0.5, -0.5, -0.5,  0.0, 1.0, 0.0,
    0.5,  0.5, -0.5,  0.0, 1.0, 0.0,
    -0.5,  0.5, -0.5,  0.0, 1.0, 0.0,

    # Top face
    -0.5,  0.5,  0.5,  0.0, 0.0, 1.0,
    0.5,  0.5,  0.5,  0.0, 0.0, 1.0,
    0.5,  0.5, -0.5,  0.0, 0.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 0.0, 1.0,

    # Bottom face
    -0.5, -0.5,  0.5,  1.0, 1.0, 0.0,
    0.5, -0.5,  0.5,  1.0, 1.0, 0.0,
    0.5, -0.5, -0.5,  1.0, 1.0, 0.0,
    -0.5, -0.5, -0.5, 1.0, 1.0, 0.0,

    # Right face
    0.5, -0.5,  0.5,  1.0, 0.0, 1.0,
    0.5, -0.5, -0.5,  1.0, 0.0, 1.0,
    0.5,  0.5, -0.5,  1.0, 0.0, 1.0,
    0.5,  0.5,  0.5,  1.0, 0.0, 1.0,

    # Left face
    -0.5, -0.5,  0.5,  0.0, 1.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0, 1.0, 1.0
  ]

  indices = [
    0, 1, 2, 2, 3, 0,       # Front face
    4, 5, 6, 6, 7, 4,       # Back face
    8, 9, 10, 10, 11, 8,    # Top face
    12, 13, 14, 14, 15, 12, # Bottom face
    16, 17, 18, 18, 19, 16, # Right face
    20, 21, 22, 22, 23, 20  # Left face
  ]

  [vertices, indices]
end

def create_sphere_vertices(radius = 0.5, segments = 20, rings = 20)
  vertices = []
  indices = []

  (0..rings).each do |i|
    phi = Math::PI * i / rings
    (0..segments).each do |j|
      theta = 2.0 * Math::PI * j / segments

      x = radius * Math.sin(phi) * Math.cos(theta)
      y = radius * Math.cos(phi)
      z = radius * Math.sin(phi) * Math.sin(theta)

      vertices << x << y << z
      vertices << ((x + radius) / (2.0 * radius))
      vertices << ((y + radius) / (2.0 * radius))
      vertices << ((z + radius) / (2.0 * radius))
    end
  end

  rings.times do |i|
    segments.times do |j|
      first = (i * (segments + 1)) + j
      second = first + segments + 1

      indices << first << second << (first + 1)
      indices << second << (second + 1) << (first + 1)
    end
  end

  [vertices, indices]
end

def perspective_matrix(fov, aspect, near, far)
  f = 1.0 / Math.tan(fov * Math::PI / 360.0)
  Matrix[
    [f / aspect, 0.0, 0.0, 0.0],
    [0.0, f, 0.0, 0.0],
    [0.0, 0.0, (far + near) / (near - far), (2.0 * far * near) / (near - far)],
    [0.0, 0.0, -1.0, 0.0]
  ]
end

def look_at_matrix(eye, center, up)
  f = Vector[center[0] - eye[0], center[1] - eye[1], center[2] - eye[2]].normalize
  s = f.cross(Vector[*up]).normalize
  u = s.cross(f)

  Matrix[
    [s[0], s[1], s[2], -s.dot(Vector[*eye])],
    [u[0], u[1], u[2], -u.dot(Vector[*eye])],
    [-f[0], -f[1], -f[2], f.dot(Vector[*eye])],
    [0.0, 0.0, 0.0, 1.0]
  ]
end

def rotation_matrix(angle, axis)
  c = Math.cos(angle)
  s = Math.sin(angle)
  t = 1.0 - c
  x, y, z = axis

  Matrix[
    [(t * x * x) + c, (t * x * y) - (s * z), (t * x * z) + (s * y), 0.0],
    [(t * x * y) + (s * z), (t * y * y) + c, (t * y * z) - (s * x), 0.0],
    [(t * x * z) - (s * y), (t * y * z) + (s * x), (t * z * z) + c, 0.0],
    [0.0, 0.0, 0.0, 1.0]
  ]
end

def translation_matrix(x, y, z)
  Matrix[
    [1.0, 0.0, 0.0, x],
    [0.0, 1.0, 0.0, y],
    [0.0, 0.0, 1.0, z],
    [0.0, 0.0, 0.0, 1.0]
  ]
end

VERTEX_SHADER = <<~GLSL
  #version 330 core
  layout (location = 0) in vec3 aPos;
  layout (location = 1) in vec3 aColor;

  out vec3 vertexColor;

  uniform mat4 model;
  uniform mat4 view;
  uniform mat4 projection;

  void main()
  {
      gl_Position = projection * view * model * vec4(aPos, 1.0);
      vertexColor = aColor;
  }
GLSL

FRAGMENT_SHADER = <<~GLSL
  #version 330 core
  in vec3 vertexColor;
  out vec4 FragColor;

  void main()
  {
      FragColor = vec4(vertexColor, 1.0);
  }
GLSL

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 3)
  GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)
  window = GLFW.CreateWindow(800, 600, 'Ruby OpenGL 3D Shapes', nil, nil)
  if window.null?
    GLFW.Terminate()
    raise 'Failed to create GLFW window'
  end

  GL.load_lib

  GLFW.MakeContextCurrent(window)

  GL.Enable(GL::DEPTH_TEST)
  shader_program = create_shader_program(VERTEX_SHADER, FRAGMENT_SHADER)

  cube_vertices, cube_indices = create_cube_vertices
  cube_vao_buf = ' ' * 4
  GL.GenVertexArrays(1, cube_vao_buf)
  cube_vao = cube_vao_buf.unpack1('I')

  cube_vbo_buf = ' ' * 4
  GL.GenBuffers(1, cube_vbo_buf)
  cube_vbo = cube_vbo_buf.unpack1('I')

  cube_ebo_buf = ' ' * 4
  GL.GenBuffers(1, cube_ebo_buf)
  cube_ebo = cube_ebo_buf.unpack1('I')

  GL.BindVertexArray(cube_vao)

  GL.BindBuffer(GL::ARRAY_BUFFER, cube_vbo)
  GL.BufferData(GL::ARRAY_BUFFER, cube_vertices.pack('f*').bytesize, cube_vertices.pack('f*'), GL::STATIC_DRAW)

  GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, cube_ebo)
  GL.BufferData(GL::ELEMENT_ARRAY_BUFFER, cube_indices.pack('I*').bytesize, cube_indices.pack('I*'), GL::STATIC_DRAW)

  GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * 4, 0)
  GL.EnableVertexAttribArray(0)

  GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * 4, 3 * 4)
  GL.EnableVertexAttribArray(1)

  sphere_vertices, sphere_indices = create_sphere_vertices

  sphere_vao_buf = ' ' * 4
  GL.GenVertexArrays(1, sphere_vao_buf)
  sphere_vao = sphere_vao_buf.unpack1('I')

  sphere_vbo_buf = ' ' * 4
  GL.GenBuffers(1, sphere_vbo_buf)
  sphere_vbo = sphere_vbo_buf.unpack1('I')

  sphere_ebo_buf = ' ' * 4
  GL.GenBuffers(1, sphere_ebo_buf)
  sphere_ebo = sphere_ebo_buf.unpack1('I')

  GL.BindVertexArray(sphere_vao)

  GL.BindBuffer(GL::ARRAY_BUFFER, sphere_vbo)
  GL.BufferData(GL::ARRAY_BUFFER, sphere_vertices.pack('f*').bytesize, sphere_vertices.pack('f*'), GL::STATIC_DRAW)

  GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, sphere_ebo)
  GL.BufferData(GL::ELEMENT_ARRAY_BUFFER, sphere_indices.pack('I*').bytesize, sphere_indices.pack('I*'), GL::STATIC_DRAW)

  GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * 4, 0)
  GL.EnableVertexAttribArray(0)

  GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * 4, 3 * 4)
  GL.EnableVertexAttribArray(1)

  model_loc = GL.GetUniformLocation(shader_program, 'model')
  view_loc = GL.GetUniformLocation(shader_program, 'view')
  projection_loc = GL.GetUniformLocation(shader_program, 'projection')

  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GLFW.SetWindowShouldClose(window, GLFW::TRUE) if GLFW.GetKey(window, GLFW::KEY_ESCAPE) == GLFW::PRESS

    GL.ClearColor(0.2, 0.3, 0.3, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    GL.UseProgram(shader_program)

    view = look_at_matrix([3.0, 3.0, 3.0], [0.0, 0.0, 0.0], [0.0, 1.0, 0.0])
    projection = perspective_matrix(45.0, 800.0 / 600.0, 0.1, 100.0)

    GL.UniformMatrix4fv(view_loc, 1, GL::TRUE, view.to_a.flatten.pack('f*'))
    GL.UniformMatrix4fv(projection_loc, 1, GL::TRUE, projection.to_a.flatten.pack('f*'))

    time = GLFW.GetTime()
    cube_model = translation_matrix(-1.5, 0.0, 0.0) * rotation_matrix(time, [0.5, 1.0, 0.0])
    GL.UniformMatrix4fv(model_loc, 1, GL::TRUE, cube_model.to_a.flatten.pack('f*'))

    GL.BindVertexArray(cube_vao)
    GL.DrawElements(GL::TRIANGLES, cube_indices.size, GL::UNSIGNED_INT, 0)

    sphere_model = translation_matrix(1.5, 0.0, 0.0) * rotation_matrix(time * 0.7, [0.0, 1.0, 0.5])
    GL.UniformMatrix4fv(model_loc, 1, GL::TRUE, sphere_model.to_a.flatten.pack('f*'))

    GL.BindVertexArray(sphere_vao)
    GL.DrawElements(GL::TRIANGLES, sphere_indices.size, GL::UNSIGNED_INT, 0)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GL.DeleteVertexArrays(1, [cube_vao].pack('I'))
  GL.DeleteBuffers(1, [cube_vbo].pack('I'))
  GL.DeleteBuffers(1, [cube_ebo].pack('I'))
  GL.DeleteVertexArrays(1, [sphere_vao].pack('I'))
  GL.DeleteBuffers(1, [sphere_vbo].pack('I'))
  GL.DeleteBuffers(1, [sphere_ebo].pack('I'))
  GL.DeleteProgram(shader_program)

  GLFW.Terminate()
end
