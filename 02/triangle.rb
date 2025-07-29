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

  void main() {
      FragColor = vec4(vertexColor, 1.0);
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

class TriangleRenderer
  def initialize
    GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
    GLFW.Init()

    GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 3)
    GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)

    @window = GLFW.CreateWindow(800, 600, 'Ruby OpenGL Triangle', nil, nil)
    if @window.null?
      puts 'Failed to create GLFW window'
      GLFW.Terminate()
      exit(-1)
    end

    GL.load_lib
    GLFW.MakeContextCurrent(@window)

    @shader_program = create_shader_program(VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE)

    setup_triangle
  end

  def setup_triangle
    vertices = [
      # pos        # color
      0.0, 0.5, 0.0, 1.0, 0.0, 0.0, # top vertex (red)
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, # left bottom vertex (green)
      0.5, -0.5, 0.0, 0.0, 0.0, 1.0 # right bottom vertex (blue)
    ]

    vao_buf = ' ' * 4
    vbo_buf = ' ' * 4
    GL.GenVertexArrays(1, vao_buf)
    GL.GenBuffers(1, vbo_buf)

    @vao = vao_buf.unpack1('I')
    @vbo = vbo_buf.unpack1('I')

    GL.BindVertexArray(@vao)

    GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
    vertices_packed = vertices.pack('f*')
    GL.BufferData(GL::ARRAY_BUFFER, vertices_packed.bytesize, vertices_packed, GL::STATIC_DRAW)

    GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * 4, 0)
    GL.EnableVertexAttribArray(0)

    GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * 4, 3 * 4)
    GL.EnableVertexAttribArray(1)

    GL.BindVertexArray(0)
  end

  def render
    until GLFW.WindowShouldClose(@window) == GLFW::TRUE
      GLFW.SetWindowShouldClose(@window, GLFW::TRUE) if GLFW.GetKey(@window, GLFW::KEY_ESCAPE) == GLFW::PRESS

      GLFW.PollEvents()

      GL.ClearColor(0.2, 0.3, 0.3, 1.0)
      GL.Clear(GL::COLOR_BUFFER_BIT)

      GL.UseProgram(@shader_program)

      GL.BindVertexArray(@vao)
      GL.DrawArrays(GL::TRIANGLES, 0, 3)
      GL.BindVertexArray(0)

      GLFW.SwapBuffers(@window)
    end
  end

  def cleanup
    GL.DeleteVertexArrays(1, [@vao].pack('I'))
    GL.DeleteBuffers(1, [@vbo].pack('I'))
    GL.DeleteProgram(@shader_program)

    GLFW.Terminate()
  end
end

# 実行
if __FILE__ == $PROGRAM_NAME
  renderer = TriangleRenderer.new
  renderer.render
  renderer.cleanup
end
