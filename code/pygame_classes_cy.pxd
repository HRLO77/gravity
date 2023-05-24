# cython: boundscheck=False
# cython: infer_types=True
# cython: language_level=3
import math, pygame
import cython
import numpy as np
cimport constants_cy as constants
cimport classes_cy as classes
cimport cython
cimport numpy as np
np.ALLOW_THREADS = True

cdef class handler:
    '''A class wrapper to handle multiple pygame sprites, wrapping particles.'''
    cdef:
        public classes.particle[:,] particles

    cdef inline classes.particle[:,] move_timestep(self):
        ...
