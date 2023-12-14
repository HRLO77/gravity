
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
    zlim = [int(input('Z bounds (integer)?: '))]*2
    zlim[0] = zlim[0]*-1
    
start_indice = input("Frame to start? [int/Enter to skip]: ")
if not start_indice.isnumeric():
    start_indice = 0
else:
    start_indice = int(start_indice)
if not bounds:
    if bool(int(input('Extra padding on dynamic bounds [1/0]?: '))):
        padding = True
        pad_x = float(input('X padding (float n>-0.5)?: '))
        pad_y = float(input('Y padding (float n>-0.5)?: '))
        pad_z = float(input('Z padding (float n>-0.5)?: '))
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
vertical = False
if move:
    vertical = bool(int(input('Vertical spin? [1/0]: ')))
    side = bool(int(input('Horizontal spin? [1/0]: ')))
LOG_INDICE = 17
save = bool(int(input('Save animation as video or render realtime? [1/0]: ')))
with open('data.pickle', 'rb') as f:
    data = pickle.load(f)[0][start_indice:]
print(len(data))
def animate(i):
    global azim, el
    try:
        ax1.clear()
        if bounds:
            ax1.set_xlim(xlim)
            ax1.set_ylim(*ylim)
            ax1.set_zlim3d(*zlim)
            
        elif padding:
            ax1.set_xmargin(pad_x)
            ax1.set_ymargin(pad_y)
            ax1.set_zmargin(pad_z)
        x = data[i]
        xs, ys, zs, mass = zip(*x)
        print(xs[LOG_INDICE], ys[LOG_INDICE], zs[LOG_INDICE], max(mass), len(mass), i, end='\r')
        # 126666666f666 for good one
        #9223372036854775807*1000000
        #6543629874590
        sizes = [(1 if i < 50_131_540_000*(6543629874590) else (2 if i < 90_131_540_000*(6543629874590) else (3 if i < 130_131_540_000*(6543629874590) else (4 if i < 170_131_540_000*(6543629874590) else (5 if i < 210_131_540_000*(6543629874590) else (6 if i < 250_131_540_000*(6543629874590) else (22 if i < 500_131_540_000*(6543629874590) else (45 if i < 802_122_547_050*(6543629874590) else 120)))))))) for i in mass]
        if move:
            if side:
                azim += 0.25
            if vertical:
                el += 0.25
            ax1.view_init(el, azim, 0)
        ax1.scatter3D(xs, ys, zs, s=sizes, depthshade=1)

        ax1.set_xlabel('Z')
        ax1.set_ylabel('X')
        ax1.set_zlabel('Y')
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
        ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=30, bitrate=-1), dpi=200)
    else:
        plt.show()
except BaseException as e:
    print('err: ', str(e))
    exit()
