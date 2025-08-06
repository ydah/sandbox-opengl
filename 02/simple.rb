require 'opengl'
require 'glfw'

VERTEX_SHADER_SOURCE = <<~GLSL
  #version 330 core
  layout (location = 0) in vec3 aPos;
  layout (location = 1) in vec3 aColor;

  out vec3 ourColor;

  void main()
  {
      gl_Position = vec4(aPos, 1.0);
      ourColor = aColor;
  }
GLSL

FRAGMENT_SHADER_SOURCE = <<~GLSL
  #version 330 core
  out vec4 FragColor;

  in vec3 ourColor;

  void main()
  {
      FragColor = vec4(ourColor, 1.0f);
  }
GLSL

if __FILE__ == $0
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()
  GL.load_lib

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 3)
  GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)
  GLFW.WindowHint(GLFW::OPENGL_FORWARD_COMPAT, GL::TRUE)

  window = GLFW.CreateWindow(800, 600, "Simple", nil, nil)
  GLFW.MakeContextCurrent(window)

  vertex_shader = GL.CreateShader(GL::VERTEX_SHADER)
  GL.ShaderSource(vertex_shader, 1, [VERTEX_SHADER_SOURCE].pack('p'), nil)
  GL.CompileShader(vertex_shader)

  success = ' ' * 4
  info_log = ' ' * 512
  GL.GetShaderiv(vertex_shader, GL::COMPILE_STATUS, success)
  if success.unpack('L')[0] == GL::FALSE
    GL.GetShaderInfoLog(vertex_shader, 512, nil, info_log)
    puts "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n#{info_log}"
  end

  fragment_shader = GL.CreateShader(GL::FRAGMENT_SHADER)
  GL.ShaderSource(fragment_shader, 1, [FRAGMENT_SHADER_SOURCE].pack('p'), nil)
  GL.CompileShader(fragment_shader)
  GL.GetShaderiv(fragment_shader, GL::COMPILE_STATUS, success)
  if success.unpack('L')[0] == GL::FALSE
    GL.GetShaderInfoLog(fragment_shader, 512, nil, info_log)
    puts "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n#{info_log}"
  end

  shader_program = GL.CreateProgram
  GL.AttachShader(shader_program, vertex_shader)
  GL.AttachShader(shader_program, fragment_shader)
  GL.LinkProgram(shader_program)
  GL.GetProgramiv(shader_program, GL::LINK_STATUS, success)
  if success.unpack('L')[0] == GL::FALSE
    GL.GetProgramInfoLog(shader_program, 512, nil, info_log)
    puts "ERROR::SHADER::PROGRAM::LINKING_FAILED\n#{info_log}"
  end
  GL.DeleteShader(vertex_shader)
  GL.DeleteShader(fragment_shader)

  # vertex data and color data for a triangle
  # X,    Y,    Z,      R,    G,    B
  vertices = [
     0.5, -0.5, 0.0,    1.0, 0.0, 0.0,  # right down (red)
    -0.5, -0.5, 0.0,    0.0, 1.0, 0.0,  # left down  (green)
     0.0,  0.5, 0.0,    0.0, 0.0, 1.0   # up         (blue)
  ].pack('F*')

  vao = ' ' * 4
  vbo = ' ' * 4
  GL.GenVertexArrays(1, vao)
  GL.GenBuffers(1, vbo)

  vao_id = vao.unpack('L')[0]
  vbo_id = vbo.unpack('L')[0]

  GL.BindVertexArray(vao_id)
  GL.BindBuffer(GL::ARRAY_BUFFER, vbo_id)
  GL.BufferData(GL::ARRAY_BUFFER, vertices.size, vertices, GL::STATIC_DRAW)
  GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * Fiddle::SIZEOF_FLOAT, 0)
  GL.EnableVertexAttribArray(0)
  GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
  GL.EnableVertexAttribArray(1)

  GL.BindBuffer(GL::ARRAY_BUFFER, 0)
  GL.BindVertexArray(0)


  while GLFW.WindowShouldClose(window) == 0
    GL.ClearColor(0.2, 0.3, 0.3, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.UseProgram(shader_program)
    GL.BindVertexArray(vao_id)
    GL.DrawArrays(GL::TRIANGLES, 0, 3)
    GLFW.SwapBuffers(window)
    GLFW.PollEvents
  end

  GL.DeleteBuffers(1, [vbo_id].pack('L'))
  GL.DeleteProgram(shader_program)
  GLFW.Terminate
end
