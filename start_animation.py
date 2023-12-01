import math

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.animation import FFMpegWriter
import matplotlib.style as mplstyle
import numpy as np
mplstyle.use('fast')
mplstyle.use(['dark_background', 'ggplot', 'fast'])

import numpy as np
bounds = not bool(int(input('Dynamic bounds [1] or static bounds [0]?: ')))
padding = False
if bounds:
    
    xlim = [int(input('X bounds (integer)?: '))]*2
    xlim[0] = xlim[0]*-1
    ylim = [int(input('Y bounds (integer)?: '))]*2
    ylim[0] = ylim[0]*-1
if not bounds:
    if bool(int(input('Extra padding on dynamic bounds [1/0]?: '))):
        padding = True
        pad_x = float(input('X padding (float 0-1)?: '))
        pad_y = float(input('Y padding (float 0-1)?: '))

fig = plt.figure()
azim = 0.0
el = 0.0
#creating a subplot
if bounds:
    plt.autoscale(False)
    plt.xlim(xlim)
    plt.ylim(ylim)
ax1 = fig.add_subplot(1, 1, 1, projection='3d')
import pickle
move = bool(int(input('Spin? [1/0]: ')))
save = bool(int(input('Save animation as video or render realtime? [1/0]: ')))
with open('data.pickle', 'rb') as f:
    data = pickle.load(f)[0]
print(len(data))
def animate(i):
    global azim, el
    try:
        ax1.clear()
        if bounds:
            ax1.set_xlim(xlim)
            ax1.set_ylim(*ylim)
        elif padding:
            ax1.set_xmargin(pad_x)
            ax1.set_ymargin(pad_y)
        x = data[i]
        xs, ys, zs, mass = zip(*x)
        # print(xs[55], ys[55], zs[55], end='\r')
        sizes = [(1 if i < 50_131_540_000*(1000000) else (2 if i < 90_131_540_000*(1000000) else (3 if i < 130_131_540_000*(1000000) else (4 if i < 170_131_540_000*(1000000) else (5 if i < 210_131_540_000*(1000000) else (6 if i < 250_131_540_000*(1000000) else (7 if i < 290_131_540_000*(1000000) else (9 if i < 402_122_547_050*(1000000) else 15)))))))) for i in mass]
        if move:
            azim += 0.15
            el += 0.15
            ax1.view_init(el, azim, 0)
        ax1.scatter3D(xs, ys, zs, s=sizes)

        ax1.set_xlabel('X')
        ax1.set_ylabel('Y')
        ax1.set_zlabel('Z')
        plt.title('Gravitational simulation')
    except BaseException as e:
        # if save:
            # ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=30))
        # else:
        print(e)
            # plt.show()
plt.ioff()

ani = animation.FuncAnimation(fig, animate, interval=1000/30, frames=len(data))
try:
    
    if save:
        ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=30, bitrate=720), dpi=720)
    else:
        plt.show()
except BaseException as e:
    print('err: ', str(e))
    exit()