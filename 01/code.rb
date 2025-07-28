# frozen_string_literal: true

require 'opengl'
require 'glfw'

key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  GLFW.SetWindowShouldClose(window, 1) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()

  window = GLFW.CreateWindow(640, 480, 'Simple example', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  GL.load_lib

  width_buf = ' ' * 8
  height_buf = ' ' * 8
  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GLFW.GetFramebufferSize(window, width_buf, height_buf)
    width = width_buf.unpack1('L')
    height = height_buf.unpack1('L')
    ratio = width.to_f / height

    GL.Viewport(0, 0, width, height)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GL.Ortho(-ratio, ratio, -1.0, 1.0, 1.0, -1.0)
    GL.MatrixMode(GL::MODELVIEW)

    GL.LoadIdentity()
    GL.Rotatef(GLFW.GetTime() * 50.0, 0.0, 0.0, 1.0)

    GL.Begin(GL::TRIANGLES)
    GL.Color3f(1.0, 0.0, 0.0)
    GL.Vertex3f(-0.6, -0.4, 0.0)
    GL.Color3f(0.0, 1.0, 0.0)
    GL.Vertex3f(0.6, -0.4, 0.0)
    GL.Color3f(0.0, 0.0, 1.0)
    GL.Vertex3f(0.0, 0.6, 0.0)
    GL.End()

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
