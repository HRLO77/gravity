# cython: language_level=3
# distutils: language=c
# cython: infer_types=True
# cython: wrap_around=False
# cython: bounds_check=False
# cython: c_division=True
# cython: overflow_check=False
# cython: none_check=False
# cython: initialized_check=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import math
from cython.parallel import prange
import numpy as np
from . import constants_cy as constants
from . import classes_cy as classes
cimport numpy as npc
cimport cython
np.ALLOW_THREADS = True

@cython.auto_pickle(True)
@cython.freelist(8192)
cdef class handler:
    '''A class wrapper to handle multiple pygame classes.particles, wrapping particles.'''
    cdef public object[:,] particles

    def __cinit__(self, int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = np.array([classes.particle.__new__(classes.particle, <unsigned int>np.round(mass), <double>x, <double>y, <double>force) for mass, x, y, force in weights])
    
    cpdef public void move_timestep(self) except *:
        '''Moves all the particles one time step.'''
        # print('running')
        # print(self.particles)
        cdef unsigned long long int length = self.particles.shape[0]
        cdef unsigned int index
        cdef object[:,] array
        for index in range(length):
            array = np.delete(self.particles, index)
            self.particles[index].move(array)  # perform calculations and move accordingly
        
    
    
    def __eq__(self, __value):
        return __value.particles == self.particles
    
    
    def __hash__(self):
        return hash(self.particles)

    def __reduce__(self):
        return (self.__class__.__new__, ((self.particles[i].mass, self.particles[i].x, self.particles[i].y, self.particles[i].force) for i in range(self.particles.shape[0])))