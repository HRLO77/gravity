import math
import numpy as np
cimport numpy as npx

#cdef public int X
#cdef public int Y 
#cdef public int X_SUB
#cdef public int Y_SUB
#cdef public (int, int) ORIGIN
# K = 50  # n particles
# grid: list[list[list]] = [[[] for y in '~'*Y] for x in '~'*X]  # grid
<<<<<<< HEAD

#cdef public float SOFTEN# the softening factor
# with open('pi.txt') as f:
#cdef public float RADIAN_DIV
#cdef public int SIZE
=======
cdef public float G # gravitational constant
#cdef public float SOFTEN# the softening factor
# with open('pi.txt') as f:
#cdef public float RADIAN_DIV
cdef public int SIZE
>>>>>>> 541eb1e03c16e7c8a337b2ad0a256db42bcaebf2
cdef public int BODIES
cdef public bint OUTPUT
cdef public float TIMESTEP
cdef public bint LOAD_DATA
#cdef public int FRAMES_F