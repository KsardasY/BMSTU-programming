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
scale = 1.


def wind(p1, p2):
    glScalef(scale * 0.25, scale * 0.25, scale * 0.25)
    glBegin(GL_QUADS)

    glColor3f(123/255, 104/255, 238/255)

    glVertex3f(1, -1, 1)
    glVertex3f(1, 1, 1)
    glVertex3f(-1, 1, 1)
    glVertex3f(-1, -1, 1)

    glVertex3f(-1, -1, 1)
    glVertex3f(-1, 1, 1)
    glVertex3f(-1, 1, -1)
    glVertex3f(-1, -1, -1)

    glVertex3f(-1, -1, -1)
    glVertex3f(-1, 1, -1)
    glVertex3f(1, 1, -1)
    glVertex3f(1, -1, -1)

    glVertex3f(1, -1, -1)
    glVertex3f(1, 1, -1)
    glVertex3f(1, 1, 1)
    glVertex3f(1, -1, 1)

    glVertex3f(1, 1, 1)
    glVertex3f(1, 1, -1)
    glVertex3f(-1, 1, -1)
    glVertex3f(-1, 1, 1)

    glVertex3f(1, -1, 1)
    glVertex3f(-1, -1, 1)
    glVertex3f(-1, -1, -1)
    glVertex3f(1, -1, -1)

    glEnd()

    glBegin(GL_LINES)
    glColor3f(0, 1, 0)
    if flag:
        glVertex3f(*p1)
        glVertex3f(*p2)
    elif p1[0] >= 1 and p2[0] <= -1 or p2[0] >= 1 and p1[0] <= -1:
        glVertex3f(p1[0]/abs(p1[0]), *p1[1:])
        glVertex3f(p2[0]/abs(p2[0]), *p2[1:])
    elif p1[1] >= 1 and p2[1] <= -1 or p2[1] >= 1 and p1[1] <= -1:
        glVertex3f(p1[0], p1[1]/abs(p1[1]), p1[-1])
        glVertex3f(p2[0], p2[1]/abs(p2[1]), p2[-1])
    elif p1[-1] >= 1 and p2[-1] <= -1 or p2[-1] >= 1 and p1[-1] <= -1:
        glVertex3f(*p1[:-1], p1[-1] / abs(p1[-1]))
        glVertex3f(*p2[:-1], p2[-1] / abs(p2[-1]))
    glEnd()


def display(window, p1, p2):
    glEnable(GL_DEPTH_TEST)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glClearColor(0, 0, 0, 0)
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    glPushMatrix()
    glRotatef(angle2, 1, 0, 0)
    glRotate(angle, 0, 0, 1)
    wind(p1, p2)
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
    """
2 0 0
-2 0 0
    """
    p1 = tuple(map(int, input().split()))
    p2 = tuple(map(int, input().split()))
    if not glfw.init():
        return
    window = glfw.create_window(800, 800, "lab5", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    while not glfw.window_should_close(window):
        display(window, p1, p2)
    glfw.destroy_window(window)
    glfw.terminate()


if __name__ == "__main__":
    main()
