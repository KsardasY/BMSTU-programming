import glfw
from OpenGL.GL import *
import math

window_size_x = 700
window_size_y = 700
data = [[255] * window_size_x for _ in range(window_size_y)]
points = []
intersections = [0] * window_size_y


def check(x, y):
    if (y + 1):
        pass


def filt():
    mask = [[1, 2, 1], [2, 4, 2], [1, 2, 1]]
    global data
    for i in range(1, window_size_y - 1):
        for j in range(1, window_size_x - 1):
            s = data[i + 1][j - 1] + data[i + 1][j] + data[i + 1][j + 1] + data[i][j - 1] + data[i][j] + data[i][j + 1] + data[i - 1][j - 1] + data[i - 1][j] + data[i - 1][j + 1]
            if s > 0:
                data[i][j] = int((1 * data[i + 1][j - 1] + 2 * data[i + 1][j] + 1 * data[i + 1][j + 1] + 2 * data[i][j - 1] + 4 * data[i][j] + 2 * data[i][j + 1] + 1 * data[i - 1][j - 1] + 2 * data[i - 1][j] + 1 * data[i - 1][j + 1]) / 16)
            else:
                data[i][j] = 0


def fill():
    Y_ = []
    X_ = []
    for point in points:
        Y_.append(point[1])
        X_.append(point[0])
    for i in range(window_size_y):
        in_ = False
        j = 0
        black = data[i].count(0)
        if black == 1:
            continue
        while j < window_size_x - 2:
            if data[i][j + 1] == 0 and not in_:
                in_ = True
                d = 0
                while data[i][j + 1] == 0:
                    if not (0 in data[i][j + 1:]):
                        break
                    d += 1
                    j += 1
                if not (0 in data[i][j + 1:]):
                    break
                # cond =  (0 not in data[i:i + 10][j - 5:j - 1]) and (0 not in data[i:i + 10][j + 1:j + 6])
                # if ([j, i] in points or (j in X_)) and cond:
                #   print("ll")
                #  in_ = False
            elif data[i][j + 1] == 0 and in_:
                in_ = False
                d = 0
                while data[i][j + 1] == 0:
                    d += 1
                    j += 1

                cond = d < 3 and (j in X_)
                if ([j, i] in points or cond) and (0 in data[i][0:j]) and (0 in data[i][j + 1:]):
                    print("hg")
                    in_ = True
            if in_:
                data[i][j + 1] = 0
            else:
                data[i][j + 1] = 255
            j += 1


def drawLine(x0, y0, x1, y1):
    global intersections
    if x0 == x1:
        m = 100000
    else:
        m = (y1 - y0) / (x1 - x0)
    e = -1 / 2
    x = x0
    y = y0
    is_sharp = True
    if x <= x1 and y <= y1:
        if m > 1:
            is_sharp = False
            m = 1 / m
        while x <= x1 and y <= y1:
            data[y][x] = 0
            if is_sharp:
                x += 1
            else:
                intersections[y] += 1
                y += 1
            e += m
            if e >= 0:
                if is_sharp:
                    intersections[y] += 1
                    y += 1
                else:
                    x += 1
                e -= 1
    elif x >= x1 and y <= y1:
        m = -m
        if m > 1:
            is_sharp = False
            m = 1 / m
        while x >= x1 and y <= y1:
            data[y][x] = 0
            if is_sharp:
                x -= 1
            else:
                intersections[y] += 1
                y += 1
            e += m
            if e >= 0:
                if is_sharp:
                    intersections[y] += 1
                    y += 1
                else:
                    x -= 1
                e -= 1
    elif x >= x1 and y >= y1:
        if m > 1:
            is_sharp = False
            m = 1 / m
        while x >= x1 and y >= y1:
            data[y][x] = 0
            if is_sharp:
                x -= 1
            else:
                intersections[y] += 1
                y -= 1
            e += m
            if e >= 0:
                if is_sharp:
                    intersections[y] += 1
                    y -= 1
                else:
                    x -= 1
                e -= 1
    elif x <= x1 and y >= y1:
        m = -m
        if m > 1:
            m = 1 / m
            is_sharp = False
        while x <= x1 and y >= y1:
            data[y][x] = 0
            if is_sharp:
                x += 1
            else:
                intersections[y] += 1
                y -= 1
            e += m
            if e >= 0:
                if is_sharp:
                    intersections[y] += 1
                    y -= 1
                else:
                    x += 1
                e -= 1


def display(window):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()
    glClearColor(0, 0, 0, 0)
    glRasterPos(-1, -1)
    glPixelZoom(2, 2)
    glDrawPixels(700, 700, GL_LUMINANCE, GL_UNSIGNED_BYTE, data)
    glfw.swap_buffers(window)
    glfw.poll_events()


def mouse_button_callback(window, button, action, mods):
    global points
    if button == glfw.MOUSE_BUTTON_LEFT and action == glfw.PRESS:
        t = glfw.get_cursor_pos(window)
        t = list(t)
        t[0] = int(t[0])
        t[1] = int(700 - t[1])
        print(t)
        if len(points) > 0:
            drawLine(points[-1][0], points[-1][1], t[0], t[1])
            intersections[points[-1][1]] -= 1
        points.append(t)


def key_callback(window, key, scancode, action, mods):
    global data
    if key == glfw.KEY_SPACE and action == glfw.PRESS:
        drawLine(points[-1][0], points[-1][1], points[0][0], points[0][1])
        intersections[points[0][1]] -= 1
        intersections[points[-1][1]] -= 1
    if key == glfw.KEY_F and action == glfw.PRESS:
        fill()
    if key == glfw.KEY_E and action == glfw.PRESS:
        filt()


def scroll_callback(window, xoffset, yoffset):
    global size
    if xoffset > 0:
        size -= yoffset / 10
    else:
        size += yoffset / 10


def main():
    if not glfw.init():
        return
    window = glfw.create_window(700, 700, "Lab4", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glfw.set_mouse_button_callback(window, mouse_button_callback)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


if __name__ == '__main__':
    main()
