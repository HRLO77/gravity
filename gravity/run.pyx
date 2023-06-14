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

from . cimport constants_cy as constants

import time

import numpy as np
from numpy import array
from numpy.random import randint


np.ALLOW_THREADS = True


cdef class Particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    cdef public float x, y
    cdef float vx, vy
    cdef int mass

    def __cinit__(self, int mass, float x, float y, float vx = 0.0, float vy = 0.0):
        self.mass = mass
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy

    cdef inline float calculate_force(self, float dist, int weight) except -1.0:
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        return (constants.G*self.mass*weight)/((dist))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)

    
    
    cdef void move(self, Particle[:,] others) except *:
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        '''Dist func: |(1/sin(θ))*base|'''
        #cdef float[:,:,] zipped, calculations
        cdef int index
        #cdef float[:,] Fx, Fy
        #cdef float net_f_x, net_f_y, net_force, vx_current, vy_current, vx_net, vy_net, f_required_x, f_required_y, force_required, direction, f, temp_dir, temp_force
        cdef float net_f_x, net_f_y, temp_dir, temp_force, to_atan, temp, x, y
        cdef int mass
        net_f_x = 0
        net_f_y = 0
        cdef Particle part
        for index in range(len(others)):
            part = <Particle>others[index]
            if self is part:
                continue

            x = part.x
            y = part.y
            mass = part.mass
            #temp_dir = self.calculate_direction((x, y))
            #temp_dir = (atan2(y-self.y, x-self.x)*constants.RADIAN_DIV)
            temp = (x-self.x)**2+(y-self.y)**2  # pythagorean theorem
            if temp < constants.SIZE:
                temp += constants.SIZE
            temp_force = self.calculate_force(temp, mass)
            #temp_force = (constants.G*self.mass*mass)/((temp))
            #temp_force = (constants.G*self.mass*others[index].mass)/((temp if temp > 0 else 1)+(constants.SOFTEN))
            net_f_x += (x-self.x)*temp_force
            net_f_y += (y-self.y)*temp_force
        #zipped = zip(*[(calculations[index][1]*cos(calculations[index][0]),calculations[index][1]*sin(calculations[index][0])) for index in arange_others])
        
        #Fx, Fy = array(zipped[0]), array(zipped[1])
        
        #net_f_x = ((sum(zipped[0])))
        #net_f_y = ((sum(zipped[1])))
        self.vx += net_f_x*constants.TIMESTEP
        self.vy += net_f_y*constants.TIMESTEP


        #vx_current = self.force * cos(self.direction,)
        #vy_current = self.force * sin(self.direction,)

        #vx_net = -(self.force * cos(self.direction,)) + (net_f_x / self.mass)
        #vy_net = -(self.force * cos(self.direction,)) + (net_f_y / self.mass)

        #f_required_x = self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass))
        #f_required_y = self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass))
        #force_required = (((self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass)))**2)+((self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass)))**2))**0.5
        
        # README: The commented out lines above are for determining velocity required to bypass pulls, if the energy of the system does not obey the laws of thermodynamics, fix HERE!

        #self.direction = atan2(net_f_y, net_f_x)
    

        #if self.force>0:self.force = (((net_force) / self.force))
        #else:self.force = (net_force) # subtract required force here
        self.x += self.vx
        self.y += self.vy
        if self.x >= constants.X_SUB:
            self.x = -constants.X_SUB
        elif self.x <= -constants.X_SUB:
            self.x = constants.X_SUB
        if self.y >= constants.Y_SUB:
            self.y = -constants.Y_SUB
        elif self.y <= -constants.Y_SUB:
            self.y = constants.Y_SUB



@cython.freelist(8192)
cdef class Handler:
    '''A class wrapper to handle multiple pygame classes.particles, wrapping particles.'''
    cdef Particle[:,] particles

    def __cinit__(self, const int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = array([Particle(np.round(mass), x, y, vx, vy) for mass, x, y, vx, vy in weights])

    
    
    cdef inline void move_timestep(self) except *:
        '''Moves all the particles one time step.'''
        cdef int length = len(self.particles)
        cdef int index
        for index in range(length):
            (<Particle>self.particles[index]).move(self.particles)
    
    cdef inline double[:,:,] get(self) except *:
        '''Returns desired data'''
        cdef int index
        return np.array([((<Particle>self.particles[index]).x, (<Particle>self.particles[index]).y) for index in range(self.particles.shape[0])])

cdef npc.ndarray[float, ndim=3] run():
    cdef float begin, end
    
    #aranged = range(constants.BODIES)
    cdef const int[:,:,] np_data = array(
        [
            (randint(10_000, 100_000), randint(-700, 700), randint(-700, 700), randint(-1, 1), randint(-1, 1))
            for i in range(constants.BODIES)
        ],
        dtype = np.int32,
    )
    cdef Handler handler = Handler(np_data)
    cdef list particles = list(handler.get())
    cdef int c = 0
    cdef int index = 0
    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                handler.move_timestep()
                particles.extend(handler.get())
                c+=1
                printf("%I64u\r", c)
                PyErr_CheckSignals()
        else:
            while 1:
                handler.move_timestep()
                particles.extend(handler.get())
                PyErr_CheckSignals()
    except BaseException as e:
        end = (time.perf_counter())
        print(f'\n\nError: {e}')
    
    print(f'\nTime: {end-begin}\n')
    printf('\nConverting to objects...\n')
    push = np.array(particles).reshape((len(particles)/constants.BODIES, constants.BODIES, 2))
    printf('\nDone!\n')
    return push
globals()['particles'] = run()