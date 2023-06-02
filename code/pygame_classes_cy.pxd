# cython: boundscheck=False
# cython: infer_types=True
# cython: language_level=3
import math, pygame
import cython
import numpy as np
from . cimport classes_cy as classes
cimport numpy as np
np.ALLOW_THREADS = True

#cdef class handler:
#    '''A class wrapper to handle multiple pygame sprites, wrapping particles.'''
#    cdef public classes.particle[:,] particles
#
#    cdef public inline classes.particle[:,] move_timestep(self):
#        ...
