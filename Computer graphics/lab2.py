import math
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
import numpy as np

object_matrix = np.identity(4)

last_mouse_x = None
last_mouse_y = None
delta_x, delta_y = 10, 10


scale = 1.0


def draw_scene():
    global object_matrix, scale
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    glPushMatrix()
    glMultMatrixf(object_matrix)

    glScalef(scale * 0.25, scale * 0.25, scale * 0.25)

    glBegin(GL_QUADS)

    glColor3f(1, 1, 1)
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

    glPopMatrix()
    glutSwapBuffers()


wireframe_mode = False


def handle_key_press(key, x, y):
    global wireframe_mode, object_matrix, delta_x, delta_y
    if key == b'q':
        wireframe_mode = not wireframe_mode
        if wireframe_mode:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
            glDisable(GL_CULL_FACE)
        else:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
            glEnable(GL_CULL_FACE)
    fl = 0
    if key == b'e':
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        matrix = [1, 0, 0, 0.1, 0, 1, 0, 0.1, 0, 0, 0, -0.1, 0, 0, 0, 1]
        glPopMatrix()
        glMultMatrixf(matrix)
    else:
        if key == b'w':
            delta_y = -10
        if key == b's':
            delta_y = 10
        if key == b'a':
            delta_x = 10
        if key == b'd':
            delta_x = -10
        rotation_y = np.identity(4)
        rotation_x = np.identity(4)
        rotation_y[0, 0] = np.cos(delta_x / 100.0)
        rotation_y[2, 0] = -np.sin(delta_x / 100.0)
        rotation_y[0, 2] = np.sin(delta_x / 100.0)
        rotation_y[2, 2] = np.cos(delta_x / 100.0)
        rotation_x[1, 1] = np.cos(delta_y / 100.0)
        rotation_x[2, 1] = np.sin(delta_y / 100.0)
        rotation_x[1, 2] = -np.sin(delta_y / 100.0)
        rotation_x[2, 2] = np.cos(delta_y / 100.0)
        object_matrix = np.dot(rotation_x, object_matrix)
        object_matrix = np.dot(rotation_y, object_matrix)
    glutPostRedisplay()


def main():
    glutInit()
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
    glutInitWindowSize(600, 600)
    glutCreateWindow(b"lab2")
    glutReshapeFunc(lambda w, h: glViewport(0, 0, w, h))
    glutKeyboardFunc(handle_key_press)
    # glutReshapeFunc(reshape)
    glEnable(GL_CULL_FACE)
    glutDisplayFunc(draw_scene)
    glutMainLoop()


if __name__ == "__main__":
    main()
