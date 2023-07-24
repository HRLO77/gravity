# cython: language_level=3
# distutils: language=c
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

#from collections import deque

from cpython.exc cimport PyErr_CheckSignals
cimport cython
cimport numpy as npc

from libc.stdio cimport printf
import pickle
from . cimport constants_cy as constants

import time

cdef extern from *:
    """
    #define GRAVITY_CONST (float)(6.67430 * 10e-11)
    """
    const float GRAVITY_CONST "GRAVITY_CONST"

import numpy as np
from numpy import array
from numpy.random import randint


np.ALLOW_THREADS = 1


cdef class Particle:
    '''Represents a single particle, can be moved according to its current state.'''


    cdef float x, y, vx, vy
    cdef float mass

    def __cinit__(self, const float mass, const float x, const float y, const float vx = 0.0, const float vy = 0.0):
        self.mass = mass
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy

    cdef inline float calculate_force(self, const float dist, const float weight):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        return (GRAVITY_CONST*self.mass*weight)/((dist))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)
    
    cdef void move(self, Particle[:,] others):
        '''Moves this particle through space based on the positions of others particles
        Parameters
        :others: An iterable of Particle objects.
        Returns void'''
        '''Dist func: |(1/sin(θ))*base|'''
        cdef int index
        cdef float net_f_x, net_f_y, temp_force, temp, x, y
        cdef float mass
        cdef Particle part
        net_f_x = 0
        net_f_y = 0
        for index in range((others.shape[0])):
            part = others[index]
            if self is part:  # ensure that we are not calculuting a particles own force
                continue

            x = part.x
            y = part.y
            mass = part.mass
            vx = part.vx
            vy = part.vy
            temp = ((x-self.x)*(x-self.x))+((y-self.y)*(y-self.y))  # pythagorean theorem
            if temp <= 10:
                temp += 10
            temp_force = self.calculate_force(temp, mass)  # calculate the attraction
            net_f_x += (x-self.x)*temp_force  # spread it accross the two dimensions
            net_f_y += (y-self.y)*temp_force

        self.vx += net_f_x*constants.TIMESTEP  # increase velocity according to gravity
        self.vy += net_f_y*constants.TIMESTEP


        self.x += self.vx  # move according to velocity
        self.y += self.vy


ctypedef (float, float) cfloat

ctypedef list[cfloat] ls_float

@cython.freelist(8192)
cdef class Handler:
    '''A class wrapper to handle multiple Particle objects easily.'''

    cdef Particle[:,] particles

    def __cinit__(self, const float[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = array([Particle(*weights[i]) for i in range((weights.shape[0]))])
    
    cdef inline void move_timestep(self):
        '''Moves all the particles one frame.'''
        cdef int index
        cdef Particle part
        for index in range(constants.BODIES):
            part = self.particles[index]
            part.move(self.particles)
    
    cdef inline ls_float get(self):
        '''Returns the position of all particles in the current frame.'''
        cdef int index
        cdef Particle part
        part = self.particles[0]
        cdef ls_float l = []
        for index in range(constants.BODIES):
            part = self.particles[index]
            l.append((part.x, part.y))
        return l



cdef npc.ndarray[float, ndim=3] run():
    cdef float begin, end
    cdef const float[:,:,] np_data
    if not constants.LOAD_DATA:
        # this line creates the particles, you can change the range of where they start, their mass, and beginning velocity to whatever you wish.
        np_data = array(
            [
                (randint(1_000_000, 2_000_000), randint(-700, 700), randint(-700, 700), randint(-1, 1), randint(-1, 1))
                for i in range(constants.BODIES)
            ],
            dtype = np.float32,
        )
    else:
        # this line loads up the last frame from data.pickle if you want to continue a simulation (very useful if you are running low on memory)
        with open('data.pickle', 'rb') as f:
            np_data = pickle.load(f)[1]
    cdef Handler handler = Handler(np_data)
    cdef list[ls_float] particles = [handler.get()]
    cdef float c = 0
    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                handler.move_timestep()
                particles.append(handler.get())
                c += 1.0
                printf("%1.f\r", c)
                PyErr_CheckSignals()
        else:
            while 1:
                # running without printing timestep is faster than doing so
                handler.move_timestep()
                particles.append(handler.get())
                PyErr_CheckSignals()
    except BaseException as e:
        end = (time.perf_counter())
        print(f'\n\nError: {e}')
    print(f'\nTime: {end-begin}\n')
    printf('\nConverting to objects...\n')
    push = np.array(particles, dtype=np.float32)#.reshape((len(particles)/constants.BODIES, constants.BODIES, 2))

    printf('\nDone!\n')
    globals()['session'] = np.array([(*pos, handler.particles[index].mass, handler.particles[index].vx, handler.particles[index].vy) for index, pos in enumerate(handler.get())], dtype=np.float32)
    return push
globals()['particles'] = run()