# frozen_string_literal: true

require 'opengl'
require 'glfw'

# Exit with ESC key
key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  GLFW.SetWindowShouldClose(window, 1) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

# Function to draw Taipei 101
def draw_taipei101(time)
  GL.PushMatrix()
  GL.Translatef(-1.5, 0.0, 0.0)
  GL.Rotatef(time * 30.0, 0.0, 1.0, 0.0)

  # Foundation (thickest part)
  GL.PushMatrix()
  GL.Translatef(0.0, -0.8, 0.0)
  GL.Scalef(0.6, 0.3, 0.6)
  GL.Color3f(0.5, 0.5, 0.5)
  draw_cube
  GL.PopMatrix()

  # Lower section
  GL.PushMatrix()
  GL.Translatef(0.0, -0.4, 0.0)
  GL.Scalef(0.5, 0.3, 0.5)
  GL.Color3f(0.6, 0.6, 0.6)
  draw_cube
  GL.PopMatrix()

  # Middle section
  GL.PushMatrix()
  GL.Translatef(0.0, 0.0, 0.0)
  GL.Scalef(0.4, 0.3, 0.4)
  GL.Color3f(0.7, 0.7, 0.7)
  draw_cube
  GL.PopMatrix()

  # Upper section
  GL.PushMatrix()
  GL.Translatef(0.0, 0.4, 0.0)
  GL.Scalef(0.3, 0.3, 0.3)
  GL.Color3f(0.8, 0.8, 0.8)
  draw_cube
  GL.PopMatrix()

  # Top (antenna part)
  GL.PushMatrix()
  GL.Translatef(0.0, 0.8, 0.0)
  GL.Scalef(0.1, 0.4, 0.1)
  GL.Color3f(0.9, 0.9, 0.9)
  draw_cube
  GL.PopMatrix()

  GL.PopMatrix()
end

# Function to draw Ruby gem
def draw_ruby_gem(time)
  GL.PushMatrix()
  GL.Translatef(1.5, 0.0, 0.0)
  GL.Rotatef(time * 50.0, 0.0, 1.0, 0.0)
  GL.Rotatef(time * 30.0, 1.0, 0.0, 0.0)

  # Upper pyramid
  GL.Begin(GL::TRIANGLES)
  # Front face
  GL.Color3f(0.8, 0.0, 0.0)
  GL.Vertex3f(0.0, 0.5, 0.0)
  GL.Color3f(0.6, 0.0, 0.0)
  GL.Vertex3f(-0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, 0.4)

  # Right face
  GL.Color3f(0.9, 0.0, 0.0)
  GL.Vertex3f(0.0, 0.5, 0.0)
  GL.Color3f(0.7, 0.0, 0.0)
  GL.Vertex3f(0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, -0.4)

  # Back face
  GL.Color3f(0.7, 0.0, 0.0)
  GL.Vertex3f(0.0, 0.5, 0.0)
  GL.Color3f(0.5, 0.0, 0.0)
  GL.Vertex3f(0.4, 0.0, -0.4)
  GL.Vertex3f(-0.4, 0.0, -0.4)

  # Left face
  GL.Color3f(0.8, 0.0, 0.0)
  GL.Vertex3f(0.0, 0.5, 0.0)
  GL.Color3f(0.6, 0.0, 0.0)
  GL.Vertex3f(-0.4, 0.0, -0.4)
  GL.Vertex3f(-0.4, 0.0, 0.4)
  GL.End()

  # Center square
  GL.Begin(GL::QUADS)
  GL.Color3f(0.9, 0.1, 0.1)
  GL.Vertex3f(-0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, -0.4)
  GL.Vertex3f(-0.4, 0.0, -0.4)
  GL.End()

  # Lower pyramid
  GL.Begin(GL::TRIANGLES)
  # Front face
  GL.Color3f(0.6, 0.0, 0.0)
  GL.Vertex3f(0.0, -0.5, 0.0)
  GL.Color3f(0.4, 0.0, 0.0)
  GL.Vertex3f(-0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, 0.4)

  # Right face
  GL.Color3f(0.7, 0.0, 0.0)
  GL.Vertex3f(0.0, -0.5, 0.0)
  GL.Color3f(0.5, 0.0, 0.0)
  GL.Vertex3f(0.4, 0.0, 0.4)
  GL.Vertex3f(0.4, 0.0, -0.4)

  # Back face
  GL.Color3f(0.5, 0.0, 0.0)
  GL.Vertex3f(0.0, -0.5, 0.0)
  GL.Color3f(0.3, 0.0, 0.0)
  GL.Vertex3f(0.4, 0.0, -0.4)
  GL.Vertex3f(-0.4, 0.0, -0.4)

  # Left face
  GL.Color3f(0.6, 0.0, 0.0)
  GL.Vertex3f(0.0, -0.5, 0.0)
  GL.Color3f(0.4, 0.0, 0.0)
  GL.Vertex3f(-0.4, 0.0, -0.4)
  GL.Vertex3f(-0.4, 0.0, 0.4)
  GL.End()

  GL.PopMatrix()
end

# Function to draw simple 3D text
def draw_3d_text(text, x, y, z, scale = 0.1)
  GL.PushMatrix()
  GL.Translatef(x, y, z)
  GL.Scalef(scale, scale, scale * 0.5)

  # Character spacing
  spacing = 1.2

  # Draw each character
  text.each_char.with_index do |char, i|
    GL.PushMatrix()
    GL.Translatef(i * spacing, 0, 0)
    draw_3d_character(char)
    GL.PopMatrix()
  end

  GL.PopMatrix()
end

# Draw individual 3D characters (simplified polygons)
def draw_3d_character(char)
  GL.Color3f(0.9, 0.9, 0.1) # Yellow

  case char.upcase
  when 'R'
    # Vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Upper horizontal line
    GL.PushMatrix()
    GL.Translatef(0, 0.4, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Middle horizontal line
    GL.PushMatrix()
    GL.Translatef(0, 0, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Upper right vertical line
    GL.PushMatrix()
    GL.Translatef(0.3, 0.2, 0)
    GL.Scalef(0.2, 0.4, 0.2)
    draw_cube
    GL.PopMatrix()

    # Diagonal line
    GL.PushMatrix()
    GL.Translatef(0.1, -0.25, 0)
    GL.Rotatef(30, 0, 0, 1)
    GL.Scalef(0.2, 0.5, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'U'
    # Left vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0.1, 0)
    GL.Scalef(0.2, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right vertical line
    GL.PushMatrix()
    GL.Translatef(0.3, 0.1, 0)
    GL.Scalef(0.2, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()

    # Bottom horizontal line
    GL.PushMatrix()
    GL.Translatef(0, -0.4, 0)
    GL.Scalef(0.8, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'B'
    # Vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Upper part
    GL.PushMatrix()
    GL.Translatef(0, 0.4, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    GL.PushMatrix()
    GL.Translatef(0.2, 0.2, 0)
    GL.Scalef(0.2, 0.4, 0.2)
    draw_cube
    GL.PopMatrix()

    # Middle part
    GL.PushMatrix()
    GL.Translatef(0, 0, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Lower part
    GL.PushMatrix()
    GL.Translatef(0, -0.4, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    GL.PushMatrix()
    GL.Translatef(0.2, -0.2, 0)
    GL.Scalef(0.2, 0.4, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'Y'
    # Upper left
    GL.PushMatrix()
    GL.Translatef(-0.2, 0.3, 0)
    GL.Rotatef(30, 0, 0, 1)
    GL.Scalef(0.2, 0.5, 0.2)
    draw_cube
    GL.PopMatrix()

    # Upper right
    GL.PushMatrix()
    GL.Translatef(0.2, 0.3, 0)
    GL.Rotatef(-30, 0, 0, 1)
    GL.Scalef(0.2, 0.5, 0.2)
    draw_cube
    GL.PopMatrix()

    # Lower part
    GL.PushMatrix()
    GL.Translatef(0, -0.2, 0)
    GL.Scalef(0.2, 0.6, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'C'
    # Upper horizontal line
    GL.PushMatrix()
    GL.Translatef(0, 0.4, 0)
    GL.Scalef(0.8, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Left vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Lower horizontal line
    GL.PushMatrix()
    GL.Translatef(0, -0.4, 0)
    GL.Scalef(0.8, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'O'
    # Upper part
    GL.PushMatrix()
    GL.Translatef(0, 0.4, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Left part
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right part
    GL.PushMatrix()
    GL.Translatef(0.3, 0, 0)
    GL.Scalef(0.2, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()

    # Lower part
    GL.PushMatrix()
    GL.Translatef(0, -0.4, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'N'
    # Left vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Diagonal line
    GL.PushMatrix()
    GL.Rotatef(30, 0, 0, 1)
    GL.Scalef(0.2, 1.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right vertical line
    GL.PushMatrix()
    GL.Translatef(0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'F'
    # Vertical line
    GL.PushMatrix()
    GL.Translatef(-0.3, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Upper horizontal line
    GL.PushMatrix()
    GL.Translatef(0.1, 0.4, 0)
    GL.Scalef(0.8, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Middle horizontal line
    GL.PushMatrix()
    GL.Translatef(0, 0, 0)
    GL.Scalef(0.6, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'T'
    # Upper horizontal line
    GL.PushMatrix()
    GL.Translatef(0, 0.4, 0)
    GL.Scalef(1.0, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Vertical line
    GL.PushMatrix()
    GL.Translatef(0, -0.1, 0)
    GL.Scalef(0.2, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'A'
    # Left diagonal line
    GL.PushMatrix()
    GL.Translatef(-0.2, 0, 0)
    GL.Rotatef(-15, 0, 0, 1)
    GL.Scalef(0.2, 1.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right diagonal line
    GL.PushMatrix()
    GL.Translatef(0.2, 0, 0)
    GL.Rotatef(15, 0, 0, 1)
    GL.Scalef(0.2, 1.2, 0.2)
    draw_cube
    GL.PopMatrix()

    # Horizontal line
    GL.PushMatrix()
    GL.Translatef(0, -0.1, 0)
    GL.Scalef(0.5, 0.2, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'I'
    # Vertical line
    GL.PushMatrix()
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

  when 'W'
    # Left outer
    GL.PushMatrix()
    GL.Translatef(-0.4, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

    # Left inner
    GL.PushMatrix()
    GL.Translatef(-0.15, -0.2, 0)
    GL.Scalef(0.2, 0.6, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right inner
    GL.PushMatrix()
    GL.Translatef(0.15, -0.2, 0)
    GL.Scalef(0.2, 0.6, 0.2)
    draw_cube
    GL.PopMatrix()

    # Right outer
    GL.PushMatrix()
    GL.Translatef(0.4, 0, 0)
    GL.Scalef(0.2, 1.0, 0.2)
    draw_cube
    GL.PopMatrix()

  when ' '
    # Space - draw nothing
  else
    # Other characters - simple rectangle
    GL.PushMatrix()
    GL.Scalef(0.8, 0.8, 0.2)
    draw_cube
    GL.PopMatrix()
  end
end

# Function to draw ground wireframe grid
def draw_ground_grid
  GL.PushMatrix()

  # Temporarily disable lighting (to make wireframe more visible)
  GL.Disable(GL::LIGHTING)

  # Grid color (light blue-green)
  GL.Color3f(0.3, 0.5, 0.6)

  # Grid size and spacing
  grid_size = 10.0
  grid_step = 0.5
  grid_count = (grid_size / grid_step).to_i

  GL.Begin(GL::LINES)

  # Lines in X direction
  (-grid_count).upto(grid_count) do |i|
    z = i * grid_step
    GL.Vertex3f(-grid_size, -1.5, z)
    GL.Vertex3f(grid_size, -1.5, z)
  end

  # Lines in Z direction
  (-grid_count).upto(grid_count) do |i|
    x = i * grid_step
    GL.Vertex3f(x, -1.5, -grid_size)
    GL.Vertex3f(x, -1.5, grid_size)
  end

  GL.End()

  # Re-enable lighting
  GL.Enable(GL::LIGHTING)

  GL.PopMatrix()
end

# Helper function to draw a cube
def draw_cube
  GL.Begin(GL::QUADS)
  # Front face
  GL.Normal3f(0.0, 0.0, 1.0)
  GL.Vertex3f(-0.5, -0.5, 0.5)
  GL.Vertex3f(0.5, -0.5, 0.5)
  GL.Vertex3f(0.5, 0.5, 0.5)
  GL.Vertex3f(-0.5, 0.5, 0.5)

  # Back face
  GL.Normal3f(0.0, 0.0, -1.0)
  GL.Vertex3f(-0.5, -0.5, -0.5)
  GL.Vertex3f(-0.5, 0.5, -0.5)
  GL.Vertex3f(0.5, 0.5, -0.5)
  GL.Vertex3f(0.5, -0.5, -0.5)

  # Top face
  GL.Normal3f(0.0, 1.0, 0.0)
  GL.Vertex3f(-0.5, 0.5, -0.5)
  GL.Vertex3f(-0.5, 0.5, 0.5)
  GL.Vertex3f(0.5, 0.5, 0.5)
  GL.Vertex3f(0.5, 0.5, -0.5)

  # Bottom face
  GL.Normal3f(0.0, -1.0, 0.0)
  GL.Vertex3f(-0.5, -0.5, -0.5)
  GL.Vertex3f(0.5, -0.5, -0.5)
  GL.Vertex3f(0.5, -0.5, 0.5)
  GL.Vertex3f(-0.5, -0.5, 0.5)

  # Right face
  GL.Normal3f(1.0, 0.0, 0.0)
  GL.Vertex3f(0.5, -0.5, -0.5)
  GL.Vertex3f(0.5, 0.5, -0.5)
  GL.Vertex3f(0.5, 0.5, 0.5)
  GL.Vertex3f(0.5, -0.5, 0.5)

  # Left face
  GL.Normal3f(-1.0, 0.0, 0.0)
  GL.Vertex3f(-0.5, -0.5, -0.5)
  GL.Vertex3f(-0.5, -0.5, 0.5)
  GL.Vertex3f(-0.5, 0.5, 0.5)
  GL.Vertex3f(-0.5, 0.5, -0.5)
  GL.End()
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()

  window = GLFW.CreateWindow(800, 600, 'Ruby + Taipei 3D', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  GL.load_lib

  # OpenGL settings
  GL.Enable(GL::DEPTH_TEST)
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::COLOR_MATERIAL)

  # Light settings
  light_position = [5.0, 5.0, 5.0, 1.0].pack('F*')
  light_ambient = [0.2, 0.2, 0.2, 1.0].pack('F*')
  light_diffuse = [0.8, 0.8, 0.8, 1.0].pack('F*')

  GL.Lightfv(GL::LIGHT0, GL::POSITION, light_position)
  GL.Lightfv(GL::LIGHT0, GL::AMBIENT, light_ambient)
  GL.Lightfv(GL::LIGHT0, GL::DIFFUSE, light_diffuse)

  width_buf = ' ' * 8
  height_buf = ' ' * 8

  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GLFW.GetFramebufferSize(window, width_buf, height_buf)
    width = width_buf.unpack1('L')
    height = height_buf.unpack1('L')
    ratio = width.to_f / height

    GL.Viewport(0, 0, width, height)
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    # Background color
    GL.ClearColor(0.1, 0.1, 0.2, 1.0)

    # Set projection matrix
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    # Set perspective projection (alternative to gluPerspective)
    fovy = 45.0
    near = 0.1
    far = 100.0
    top = near * Math.tan(fovy * Math::PI / 360.0)
    bottom = -top
    left = bottom * ratio
    right = top * ratio
    GL.Frustum(left, right, bottom, top, near, far)

    # Set model-view matrix
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()

    # Camera settings (rotate entire scene)
    time = GLFW.GetTime()
    GL.Translatef(0.0, 0.0, -6.0)
    GL.Rotatef(20.0, 1.0, 0.0, 0.0)
    GL.Rotatef(time * 20.0, 0.0, 1.0, 0.0)

    # Draw objects
    draw_ground_grid
    draw_taipei101(time)
    draw_ruby_gem(time)

    # Draw RubyConf Taiwan text
    GL.PushMatrix()
    GL.Rotatef(Math.sin(time * 0.5) * 10, 0, 1, 0) # Gentle swaying rotation
    draw_3d_text('RUBYCONF', -1.0, 1.8, 0, 0.15)
    draw_3d_text('TAIWAN', -0.5, 1.5, 0, 0.15)
    GL.PopMatrix()

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
