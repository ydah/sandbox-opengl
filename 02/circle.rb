# frozen_string_literal: true

require 'opengl'
require 'glfw'

VERTEX_SHADER_SOURCE = <<~GLSL
  #version 330 core
  layout (location = 0) in vec3 aPos;
  layout (location = 1) in vec3 aColor;

  out vec3 vertexColor;

  void main() {
      gl_Position = vec4(aPos, 1.0);
      vertexColor = aColor;
  }
GLSL

FRAGMENT_SHADER_SOURCE = <<~GLSL
  #version 330 core
  out vec4 FragColor;
  in vec3 vertexColor;

  uniform float time;

  void main() {
      float pulse = (sin(time * 2.0) + 1.0) * 0.5;
      vec3 finalColor = vertexColor * (0.7 + 0.3 * pulse);
      FragColor = vec4(finalColor, 1.0);
  }
GLSL

def compile_shader(type, source)
  shader = GL.CreateShader(type)
  GL.ShaderSource(shader, 1, [source].pack('p'), [source.bytesize].pack('I'))
  GL.CompileShader(shader)

  status_buf = ' ' * 4
  GL.GetShaderiv(shader, GL::COMPILE_STATUS, status_buf)
  status = status_buf.unpack1('I')

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
  GL.GetProgramiv(program, GL::LINK_STATUS, status_buf)
  status = status_buf.unpack1('I')

  if status == GL::FALSE
    log = GL.GetProgramInfoLog(program)
    raise "Program link error: #{log}"
  end

  GL.DeleteShader(vertex_shader)
  GL.DeleteShader(fragment_shader)

  program
end

class CircleRenderer
  def initialize
    GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
    GLFW.Init()

    GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 3)
    GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)

    @window = GLFW.CreateWindow(800, 600, 'Ruby OpenGL Circle', nil, nil)
    if @window.null?
      puts 'Failed to create GLFW window'
      GLFW.Terminate()
      exit(-1)
    end

    GL.load_lib
    GLFW.MakeContextCurrent(@window)

    @shader_program = create_shader_program(VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

    setup_circle

    @start_time = GLFW.GetTime()
  end

  def setup_circle
    segments = 36
    radius = 0.5
    vertices = []
    indices = []

    vertices += [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]

    (0..segments).each do |i|
      angle = 2.0 * Math::PI * i / segments
      x = radius * Math.cos(angle)
      y = radius * Math.sin(angle)

      hue = i.to_f / segments * 360
      rgb = hsv_to_rgb(hue, 1.0, 1.0)

      vertices += [x, y, 0.0, rgb[0], rgb[1], rgb[2]]
    end

    (0...segments).each do |i|
      indices += [0, i + 1, i + 2]
    end

    @vertex_count = indices.length

    vao_buf = ' ' * 4
    vbo_buf = ' ' * 4
    ebo_buf = ' ' * 4
    GL.GenVertexArrays(1, vao_buf)
    GL.GenBuffers(1, vbo_buf)
    GL.GenBuffers(1, ebo_buf)

    @vao = vao_buf.unpack1('I')
    @vbo = vbo_buf.unpack1('I')
    @ebo = ebo_buf.unpack1('I')

    GL.BindVertexArray(@vao)

    GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
    vertices_packed = vertices.pack('f*')
    GL.BufferData(GL::ARRAY_BUFFER, vertices_packed.bytesize, vertices_packed, GL::STATIC_DRAW)

    GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)
    indices_packed = indices.pack('I*')
    GL.BufferData(GL::ELEMENT_ARRAY_BUFFER, indices_packed.bytesize, indices_packed, GL::STATIC_DRAW)

    GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * 4, 0)
    GL.EnableVertexAttribArray(0)

    GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * 4, 3 * 4)
    GL.EnableVertexAttribArray(1)

    GL.BindVertexArray(0)
  end

  def hsv_to_rgb(h, s, v)
    h /= 60.0
    i = h.floor
    f = h - i
    p = v * (1 - s)
    q = v * (1 - (s * f))
    t = v * (1 - (s * (1 - f)))

    case i % 6
    when 0
      [v, t, p]
    when 1
      [q, v, p]
    when 2
      [p, v, t]
    when 3
      [p, q, v]
    when 4
      [t, p, v]
    when 5
      [v, p, q]
    end
  end

  def render
    until GLFW.WindowShouldClose(@window) == GLFW::TRUE
      GLFW.SetWindowShouldClose(@window, GLFW::TRUE) if GLFW.GetKey(@window, GLFW::KEY_ESCAPE) == GLFW::PRESS

      GLFW.PollEvents()

      GL.ClearColor(0.1, 0.1, 0.1, 1.0)
      GL.Clear(GL::COLOR_BUFFER_BIT)

      GL.UseProgram(@shader_program)

      current_time = GLFW.GetTime() - @start_time
      time_location = GL.GetUniformLocation(@shader_program, 'time')
      GL.Uniform1f(time_location, current_time)

      GL.BindVertexArray(@vao)
      GL.DrawElements(GL::TRIANGLES, @vertex_count, GL::UNSIGNED_INT, 0)
      GL.BindVertexArray(0)

      GLFW.SwapBuffers(@window)
    end
  end

  def cleanup
    GL.DeleteVertexArrays(1, [@vao].pack('I'))
    GL.DeleteBuffers(1, [@vbo].pack('I'))
    GL.DeleteBuffers(1, [@ebo].pack('I'))
    GL.DeleteProgram(@shader_program)

    GLFW.Terminate()
  end
end

if __FILE__ == $PROGRAM_NAME
  renderer = CircleRenderer.new
  renderer.render
  renderer.cleanup
end
