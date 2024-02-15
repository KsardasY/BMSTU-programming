import glfw
from OpenGL.GL import *
import math

tetha = 5
phi = 1
size = 0.3
angle = 0.0
angle2 = 10
delta = 3
n = 2
flag = True
participates = 20
a, b = 0, 0


def ellipsoid():
    global size
    for j in range(-b + 1, b + 1):
        glBegin(GL_QUAD_STRIP)
        i = 0
        while i <= 2 * math.pi:
            upper_size = (1 - (a * (j - 1) / b)**2)**0.5
            lower_size = (1 - (a * j / b) ** 2) ** 0.5
            x = size * math.cos(i)
            y = size * math.sin(i)
            glColor3f(x * 4.3, y * 7.4, 0.65)
            glVertex3f(x * upper_size, y * upper_size, (j - 1) / b)
            glVertex3f(x * lower_size, y * lower_size, j / b)
            i += math.pi / participates
        glEnd()


def display(window):
    glEnable(GL_DEPTH_TEST)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glClearColor(0, 0, 0, 0)
    if flag:
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else:
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    glPushMatrix()
    glRotatef(angle2, 1, 0, 0)
    glRotate(angle, 0, 0, 1)
    ellipsoid()
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
        if key == glfw.KEY_SPACE:
            flag = not flag


def main():
    global a, b
    if not glfw.init():
        return
    window = glfw.create_window(800, 800, "lab3", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    a, b = map(int, input().split())
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


if __name__ == "__main__":
    main()
