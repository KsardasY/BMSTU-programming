import glfw
import glm
from OpenGL.GL import *
from math import *


tetha = 5
phi = 1
size = 0.3
angle = 0.0
angle2 = 10
delta = 3
pointdata = []
pointcolor = []
n = 0
v0 = 0
g = 0.00099
surface = -3.3
h0 = 0
participates = 20
a, b = 1, 5


def create_shader(shader_type, source):
    shader = glCreateShader(shader_type)
    glShaderSource(shader, source)
    glCompileShader(shader)
    return shader


def create_figure(x, y, z):
    global pointdata
    global pointcolor
    global n
    pointdata = []
    pointcolor = []
    n = 0
    for j in range(-b + 1, b + 1):
        i = 0
        while i <= 2 * pi:
            upper_size = (1 - (a * (j - 1) / b)**2)**0.5
            lower_size = (1 - (a * j / b) ** 2) ** 0.5
            x = cos(i)
            y = sin(i)
            pointdata.append((x * upper_size, y * upper_size, (j - 1) / b))
            pointdata.append((x * lower_size, y * lower_size, j / b))
            pointcolor.append((x * 4.3, y * 7.4, 0.65))
            pointcolor.append((x * 4.3, y * 7.4, 0.65))
            n += 2
            # glColor3f(x * 4.3, y * 7.4, 0.65)
            # glVertex3f(x * upper_size, y * upper_size, (j - 1) / b)
            # glVertex3f(x * lower_size, y * lower_size, j / b)
            i += pi / participates


def display(window):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_COLOR_ARRAY)
    glVertexPointer(3, GL_FLOAT, 0, pointdata)
    glColorPointer(3, GL_FLOAT, 0, pointcolor)
    glPushMatrix()
    glRotatef(angle2, 1, 0, 0)
    glRotate(angle, 0, 0, 1)
    glDrawArrays(GL_QUAD_STRIP, 0, n)
    glDisableClientState(GL_VERTEX_ARRAY)
    glDisableClientState(GL_COLOR_ARRAY)
    # global v0
    # global h0
    # glTranslatef(0, v0, 0)
    # h0 += v0
    # v0 -= g
    # if h0 <= surface:
    #     v0 = -1 * v0
    glPopMatrix()
    glfw.swap_buffers(window)
    glfw.poll_events()


def key_callback(window, key, scancode, action, mods):
    global angle, angle2, flag, participates
    if action == glfw.REPEAT or action == glfw.PRESS:
        if key == glfw.KEY_RIGHT:
            angle += delta
        if key == glfw.KEY_LEFT:
            angle -= delta
        if key == glfw.KEY_UP:
            angle2 += delta
        if key == glfw.KEY_DOWN:
            angle2 -= delta
        if key == glfw.KEY_MINUS:
            if participates > 1:
                participates -= 1
        if key == glfw.KEY_EQUAL:
            participates += 1


def main():
    if not glfw.init():
        return
    window = glfw.create_window(900, 900, "lab8", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    vertex = create_shader(GL_VERTEX_SHADER, """
                varying vec4 vertex_color;
                void main(){
                    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
                    vertex_color = gl_Color;
                }""")
    fragment = create_shader(GL_FRAGMENT_SHADER, """
            varying vec4 vertex_color;
            void main() {
                gl_FragColor = vertex_color;
            }""")
    program = glCreateProgram()
    glAttachShader(program, vertex)
    glAttachShader(program, fragment)
    glLinkProgram(program)
    glScalef(0.3, 0.3, 0.3)
    create_figure(0, -3, 0)
    glUseProgram(program)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


if __name__ == "__main__":
    main()
