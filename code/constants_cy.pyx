# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import math
import numpy as np
cimport numpy as np

np.ALLOW_THREADS = True
cdef int X = 1800
cdef int Y = 1200
cdef int X_SUB = np.ceil(X/2)
cdef int Y_SUB = np.ceil(Y/2)
cdef (int, int) ORIGIN = (X-X_SUB, Y-Y_SUB)
# K = 50  # n particles
# grid: list[list[list]] = [[[] for y in '~'*Y] for x in '~'*X]  # grid
cdef float G = 6.67430*10e-11  # gravitational constant
cdef float SOFTEN = 10e-20  # the softening factor
# with open('pi.txt') as f:
cdef float RADIAN_DIV = 180/np.pi
cdef int SIZE = 5
cdef float FACTOR=float(input("Enter factor: "))
cdef int BODIES = int(input("Enter bodies: "))
cdef bint DISSIPATE = bool(int(input('Enter dissipation: ')))