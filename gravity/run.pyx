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


from cpython.exc cimport PyErr_CheckSignals
cimport cython
cimport numpy as npc

from libc.stdio cimport printf
import pickle
from . cimport constants_cy as constants

import time

import numpy as np
from numpy import array
from numpy.random import randint


np.ALLOW_THREADS = True


cdef class Particle:
    '''Represents a single particle, can be moved according to its current state.'''
    cdef public float x, y
    cdef float vx, vy
    cdef unsigned int mass

    def __cinit__(self, unsigned int mass, float x, float y, float vx = 0.0, float vy = 0.0):
        self.mass = mass
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy

    cdef inline float calculate_force(self, float dist, unsigned int weight) except -1.0:
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        return (constants.G*self.mass*weight)/((dist))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)
    
    
    cdef void move(self, Particle[:,] others) except *:
        '''Moves this particle through space based on the positions of others particles
        Parameters
        :others: An iterable of Particle objects.
        Returns void'''
        '''Dist func: |(1/sin(θ))*base|'''
        cdef unsigned int index
        cdef float net_f_x, net_f_y, temp_dir, temp_force, to_atan, temp, x, y
        cdef unsigned int mass

        net_f_x = 0
        net_f_y = 0
        for index in range((others.shape[0])):

            if self is others[index]:  # ensure that we are not calculuting a particles own force
                continue

            x = others[index].x
            y = others[index].y
            mass = others[index].mass

            temp = (x-self.x)**2+(y-self.y)**2  # pythagorean theorem
            if temp < constants.SIZE:
                temp += constants.SIZE
            temp_force = self.calculate_force(temp, mass)  # calculate the attraction
            net_f_x += (x-self.x)*temp_force  # spread it accross the two dimensions
            net_f_y += (y-self.y)*temp_force

        self.vx += net_f_x*constants.TIMESTEP  ## increase velocity according to gravity
        self.vy += net_f_y*constants.TIMESTEP


        self.x += self.vx  # move according to velocity
        self.y += self.vy



@cython.freelist(8192)
cdef class Handler:
    '''A class wrapper to handle multiple Particle objects easily.'''
    cdef Particle[:,] particles

    def __cinit__(self, const int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = array([Particle(*weights[i]) for i in range((weights.shape[0]))])
    
    cdef inline void move_timestep(self) except *:
        '''Moves all the particles one frame.'''
        cdef unsigned int index
        cdef Particle part
        for index in range(constants.BODIES):
            part = self.particles[index]
            (part).move(self.particles)
    
    cdef inline list get(self):
        '''Returns the position of all particles in the current frame.'''
        cdef unsigned int index
        cdef list l = []
        cdef Particle part
        for index in range(constants.BODIES):
            part = self.particles[index]
            l.extend(((part.x, part.y), ))
        return l

cdef npc.ndarray[float, ndim=3] run():
    cdef float begin, end
    
    cdef const int[:,:,] np_data
    if not constants.LOAD_DATA:
        # this line creates the particles, you can change the range of where they start, their mass, and beginning velocity to whatever you wish.
        np_data = array(
            [
                (randint(1_000_000, 2_000_000), randint(-700, 700), randint(-700, 700), randint(-1, 1), randint(-1, 1))
                for i in range(constants.BODIES)
            ],
            dtype = np.int32,
        )
    else:
        # this line loads up the last frame from data.pickle if you want to continue a simulation (very useful if you are running low on memory)
        with open('data.pickle', 'rb') as f:
            np_data = pickle.load(f)[1]
    cdef Handler handler = Handler(np_data)
    cdef list particles = list(handler.get())
    cdef unsigned int c = 0
    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                handler.move_timestep()
                particles.extend(handler.get())
                c+=1
                printf("%i\r", c)
                PyErr_CheckSignals()
        else:
            while 1:
                # running without printing timestep is faster than doing so
                handler.move_timestep()
                particles.extend(handler.get())
                PyErr_CheckSignals()
    except BaseException as e:
        end = (time.perf_counter())
        print(f'\n\nError: {e}')
    
    print(f'\nTime: {end-begin}\n')
    printf('\nConverting to objects...\n')
    push = np.array(particles, dtype=np.float16).reshape((len(particles)/constants.BODIES, constants.BODIES, 2))

    printf('\nDone!\n')
    c=0
    globals()['session'] = np.array([(handler.particles[c].x, handler.particles[c].y, handler.particles[c].mass, handler.particles[c].vx, handler.particles[c].vy) for c in range((handler.particles.shape[0]))], dtype=np.int32)
    return push
globals()['particles'] = run()