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
fig = plt.figure()

#creating a subplot 
ax1 = fig.add_subplot(1,1,1)

import pickle
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
        ax1.scatter(*zip(*dat), con)
        plt.xlabel('X')
        plt.ylabel('Y')
        plt.title('Gravitational simulation')
    except BaseException:
        if save:
            ani.save(f'./{np.random.randint(0, 2_000_000)}.mp4', writer=FFMpegWriter(fps=30))
        else:
            plt.show()
plt.ioff()
ani = animation.FuncAnimation(fig, animate, interval=1 if save else 1000/30, cache_frame_data=data.shape[1] < 3_000, frames=data.shape[0], repeat=False)
try:
    if save:
        ani.save(f'./{np.random.randint(0, 2_000_000)}.mp4', writer=FFMpegWriter(fps=30))
    else:
        plt.show()
except BaseException:
    exit()