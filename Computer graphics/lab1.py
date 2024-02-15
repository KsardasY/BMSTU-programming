import glfw
from OpenGL.GL import *

delta = 0.2
angle = 0.0
posx = 0.0
posy = 0.0
size = 0.0
f = False


def main():
    if not glfw.init():
        return
    window = glfw.create_window(640, 640, "lab1", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


def display(window):
    global angle
    glClear(GL_COLOR_BUFFER_BIT)
    glLoadIdentity()
    glClearColor(1, 1.0, 1.0, 1)
    glPushMatrix()
    glPointSize(50)
    glRotatef(angle, 0, 0, 1)
    glBegin(GL_POINTS)
    glColor3f(0, 0, 0)
    glVertex2f(posx + size + -0.5, posy - size + -0.5)
    glVertex2f(posx - size, posy + size + 0.4)
    glVertex2f(posx - size + 0.4, posy - size)
    glVertex2f(posx - size, posy + size + 0.15)
    glVertex2f(posx - size + 0.15, posy - size)
    glVertex2f(posx - size - 0.3, posy + size - 0.4)
    glVertex2f(posx - size - 0.4, posy - size - 0.3)
    glEnd()
    glPointSize(100)
    glBegin(GL_POINTS)
    glVertex2f(posx + size + 0.5, posy + size + 0.5)
    glVertex2f(posx - size + 0.2, posy - size + 0.2)
    glEnd()
    glPopMatrix()
    angle += delta
    glfw.swap_buffers(window)
    glfw.poll_events()


def key_callback(window, key, scancode, action, mods):
    global f
    global delta
    global angle
    if action == glfw.PRESS:
        if key == glfw.KEY_SPACE:
            f = not f
            if f:
                delta = 0
            else:
                delta = 0.2


if __name__ == "__main__":
    main()
