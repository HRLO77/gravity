# cython: language_level=3
# distutils: language=c
# cython: infer_types=False
# cython: wraparound=False
# cython: boundscheck=False
# cython: cdivision=True
# cython: overflowcheck=False
# cython: nonecheck=False
# cython: initializedcheck=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import math
import numpy as np
cimport numpy as np

np.ALLOW_THREADS = True
cdef public int X = 1920
cdef public int Y = 1080
cdef public int X_SUB = np.ceil(X/2)
cdef public int Y_SUB = np.ceil(Y/2)
cdef public (int, int) ORIGIN = (X-X_SUB, Y-Y_SUB)
# K = 50  # n particles
# grid: list[list[list]] = [[[] for y in '~'*Y] for x in '~'*X]  # grid
cdef public float G = 6.67430*10e-11  # gravitational constant
cdef public float SOFTEN = 10e-20  # the softening factor
# with open('pi.txt') as f:
cdef public float RADIAN_DIV = np.pi/180
cdef public int SIZE = 5
cdef public int BODIES = int(input("Enter bodies: "))
cdef public bint OUTPUT = bool(int(input('Print progress?: ')))
cdef public float TIMESTEP = 0.01

__all__ = globals()