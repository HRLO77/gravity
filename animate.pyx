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
import numpy as np
cimport numpy as npc
import time
fig = plt.figure()

#creating a subplot 
ax1 = fig.add_subplot(1,1,1)

import pickle
with open('data.pickle', 'rb') as f:
    data = pickle.load(f)[0]

cdef unsigned char[:,] con = np.array([2 for i in range(data.shape[1])], dtype=np.ubyte)
cdef unsigned int c = 0
cdef inline void animate(i):
    
    global c, con
   
    
    ax1.clear()
    ax1.scatter(*zip(*data[c]), con)

    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('Gravitational simulation')
    c += 1
    
ani = animation.FuncAnimation(fig, animate, interval=1000/30, save_count=30)
plt.show()