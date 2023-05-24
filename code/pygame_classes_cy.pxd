# cython: boundscheck=False
# cython: infer_types=True
# cython: language_level=3
import cython
import math, pygame
import constants_cy as constants
cimport constants_cy as constants
import numpy as np
import classes_cy as classes
cimport classes_cy as classes
cimport cython
cimport numpy as np
cimport classes_cy as classes
np.ALLOW_THREADS = True

cdef class handler:
    '''A class wrapper to handle multiple pygame sprites, wrapping particles.'''
    cdef:
        public classes.particle[:,] particles

    cdef inline classes.particle[:,] move_timestep(self):
        ...
