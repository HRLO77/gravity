import math
import numpy as np
cimport numpy as np

cdef int X
cdef int Y 
cdef int X_SUB
cdef int Y_SUB
cdef (int, int) ORIGIN
# K = 50  # n particles
# grid: list[list[list]] = [[[] for y in '~'*Y] for x in '~'*X]  # grid
cdef float G # gravitational constant ant
cdef float SOFTEN# the softening factor
# with open('pi.txt') as f:
cdef float RADIAN_DIV
cdef int SIZE
cdef float FACTOR
cdef int BODIES
cdef bint DISSIPATE