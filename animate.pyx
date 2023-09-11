# cython: language_level=3
# distutils: language=c
# cython: cpp_locals=True
# cythhon: binding=False
# cython: infer_types=False
# cython: wraparound=False
# cython: boundscheck=False
# cython: cdivision=True
# cython: overflowcheck=False
# cython: nonecheck=False
# cython: initializedcheck=False
# cython: always_allow_keywords=False
# cython: c_api_binop_methods=True
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.animation import FFMpegWriter
import numpy as np
cimport numpy as npc
import pickle

#creating a subplot 


import pickle
import matplotlib.style as mplstyle
mplstyle.use('fast')
mplstyle.use(['dark_background', 'ggplot', 'fast'])

cdef bint bounds, padding
bounds = False
padding = False
cdef (int, int) xlim, ylim
cdef float pad_x, pad_y
bounds = not bool(int(input('Dynamic bounds [1] or static bounds [0]?: ')))
if bounds:
    xlim = tuple([int(input('X bounds (integer)?: '))]*2)
    xlim[0] = xlim[0]*-1
    ylim = tuple([int(input('Y bounds (integer)?: '))]*2)
    ylim[0] = ylim[0]*-1
if not bounds:
    if bool(int(input('Extra padding on dynamic bounds [1/0]?: '))):
        padding = True
        pad_x = float(input('X padding (float 0-1)?: '))
        pad_y = float(input('Y padding (float 0-1)?: '))
fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)
#creating a subplot
if bounds:
    plt.autoscale(False)
    plt.xlim(xlim)
    plt.ylim(ylim)

cdef bint save = bool(int(input('Save animation as video or render realtime? [1/0]: ')))
cdef float[:,:,:,] data
with open('data.pickle', 'rb') as f:
    data = np.array(pickle.load(f)[0], dtype=np.float32)
cdef unsigned char[:,] con = np.array([1 for i in range(data.shape[1])], dtype=np.ubyte)
cdef inline void animate(unsigned int i):
    cdef float[:,:,] dat
    try:
        global c, con
        ax1.clear()
        dat = data[i]
        if bounds:
            ax1.set_xlim(xlim)
            ax1.set_ylim(*ylim)
        elif padding:
            ax1.set_xmargin(pad_x)
            ax1.set_ymargin(pad_y)
            
        ax1.scatter(*zip(*dat), con)

        plt.xlabel('X')
        plt.ylabel('Y')
        plt.title('Gravitational simulation')
    except BaseException:
        if save:
            ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=25))
        else:
            plt.show()
plt.ioff()
ani = animation.FuncAnimation(fig, animate, interval=1 if save else 1000/25, cache_frame_data=data.shape[1] < 5_000, frames=data.shape[0], repeat=False)
try:
    if save:
        ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=25))
    else:
        plt.show()
except BaseException:
    exit()