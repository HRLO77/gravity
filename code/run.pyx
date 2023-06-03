# cython: language_level=3
# distutils: language=c
# cython: infer_types=True
# cython: wrap_around=False
# cython: bounds_check=False
# cython: cdivision=True
# cython: overflow_check=False
# cython: none_check=False
# cython: initialized_check=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import pickle, random
from numpy import array, append
from . cimport constants_cy as constants
import time
from numpy.random import randint
from libc.stdio cimport printf
import math
from numpy import array
cimport numpy as npc
import numpy as np
cimport cython
from libc.math cimport sin, cos, atan2, fabs
np.ALLOW_THREADS = True

cdef class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    cdef public double x, direction, y, force
    cdef public unsigned int mass

    def __cinit__(self, int mass, double x, double y , double force = 0):
        self.mass = <unsigned int>mass
        self.x = <double>x
        self.y = <double>y
        self.direction = 1.0
        self.force = <double>force
        
      
    cdef public inline double calculate_force(self, (double, double) position, unsigned int weight, double angle) except -1.0:
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        return (constants.G*self.mass*weight)/(fabs(position[0]**2)+fabs(position[1])**2+(constants.SOFTEN))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)
        
      
    cdef public inline double calculate_direction(self, (double, double) position, double angle) except -1.0:
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        #return (atan2(position[1]-self.y, position[0]-self.x)/constants.RADIAN_DIV)
        return fabs((1/sin(angle))*position[0]-self.x)
    
    #cdef public inline (double, double) trig_put(self, double direction):
    #    '''Applies cosine and sine to the direction and returns a vector in that order.'''
    #    return (cos(direction), sin(direction))
      
    cdef public void move(self, particle[:,] others) except *:
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        '''Dist func: |(1/sin(θ))*base|'''
        #cdef double[:,:,] zipped, calculations
        cdef unsigned int index
        #cdef double[:,] Fx, Fy
        #cdef double net_f_x, net_f_y, net_force, vx_current, vy_current, vx_net, vy_net, f_required_x, f_required_y, force_required, direction, f, temp_dir, temp_force
        cdef double net_f_x, net_f_y, net_force, temp_dir, temp_force, to_atan
        net_f_x, net_f_y = (0, 0)
        arange_others = range(others.shape[0])
        #calculations = array([(self.calculate_direction((others[index].x, others[index].y)), self.calculate_force((others[index].x, others[index].y), others[index].mass)) for index in arange_others])
        #zipped = array([*zip(*[array([self.calculate_force((others[index].x, others[index].y), others[index].mass)]*2)*self.trig_put(self.calculate_direction((others[index].x, others[index].y))) for index in arange_others])])
        for index in arange_others:
            to_atan = atan2(others[index].y-self.y, others[index].x-self.x)
            temp_dir = self.calculate_direction((others[index].x, others[index].y), to_atan)
            temp_force = self.calculate_force((others[index].x, others[index].y), others[index].mass, to_atan)
            net_f_x += cos(temp_dir)*temp_force
            net_f_x += sin(temp_dir)*temp_force
        #zipped = zip(*[(calculations[index][1]*cos(calculations[index][0]),calculations[index][1]*sin(calculations[index][0])) for index in arange_others])
        
        #Fx, Fy = array(zipped[0]), array(zipped[1])
        
        #net_f_x = ((sum(zipped[0])))
        #net_f_y = ((sum(zipped[1])))

        net_force = (((net_f_x**2) + (net_f_y**2))*0.1)  # may have to perform **0.5 maybe?

        #vx_current = self.force * cos(self.direction,)
        #vy_current = self.force * sin(self.direction,)

        #vx_net = -(self.force * cos(self.direction,)) + (net_f_x / self.mass)
        #vy_net = -(self.force * cos(self.direction,)) + (net_f_y / self.mass)

        #f_required_x = self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass))
        #f_required_y = self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass))
        #force_required = (((self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass)))**2)+((self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass)))**2))**0.5
        
        # README: The commented out lines above are for determining velocity required to bypass pulls, if the energy of the system does not obey the laws of thermodynamics, fix HERE!

        self.direction = atan2(net_f_y, net_f_x)
    

        if self.force>0:self.force = (((net_force / (self.force))))
        else:self.force = (net_force) # subtract required force here
        self.goto()
        return

    
    cdef public inline void goto(self) except *:
        '''Moves X and Y position based on a timestep, current direction and force.'''
        cdef double far
        cdef double move_x
        cdef double move_y
        far = self.direction*constants.RADIAN_DIV
        if constants.DISSIPATE:self.force = self.force-((self.force*0.001 if not(self.force==np.nan or self.force==0) else 0))  # attempted reality :(
        move_x = (cos(far,))
        move_y = (sin(far,))
        self.x += move_x
        self.y += move_y
        if self.x >= constants.X_SUB:
            self.x = -constants.X_SUB
        elif self.x <= -constants.X_SUB:
            self.x = constants.X_SUB
        if self.y >= constants.Y_SUB:
            self.y = -constants.Y_SUB
        elif self.y <= -constants.Y_SUB:
            self.y = constants.Y_SUB
        return
    
    def __eq__(self, __value):
        return (self.force, self.x, self.y, self.mass, self.direction) == (__value.force, __value.x, __value.y, __value.mass, __value.direction)
    
    
    def __hash__(self):
        return hash((self.force, self.x, self.y, self.mass, self.direction))

    def __reduce__(self):
        return (self.__class__.__new__, (self.__class__, self.mass, self.x, self.y, self.force))

@cython.freelist(8192)
cdef class hand:
    '''A class wrapper to handle multiple pygame classes.particles, wrapping particles.'''
    cdef public particle[:,] particles

    def __cinit__(self, int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = array([particle.__new__(particle, <unsigned int>np.round(mass), <double>x, <double>y, <double>force) for mass, x, y, force in weights])
    
    cdef public inline void move_timestep(self) except *:
        '''Moves all the particles one time step.'''
        cdef unsigned long long int length = self.particles.shape[0]
        cdef unsigned int index
        #cdef object[:,] array
        for index in range(length):
            #array = np.delete(self.particles, index)
            self.particles[index].move(np.delete(self.particles, index))  # perform calculations and move accordingly
        
    def __eq__(self, __value):
        return __value.particles == self.particles
    
    
    def __hash__(self):
        return hash(self.particles)

    def __reduce__(self):
        return (self.__class__.__new__, ((self.particles[i].mass, self.particles[i].x, self.particles[i].y, self.particles[i].force) for i in range(self.particles.shape[0])))


cdef npc.ndarray[object, ndim=2] run() except *:
    cdef double begin, end
    begin = <double>(time.perf_counter())
    #aranged = range(constants.BODIES)
    cdef int[:,:,] np_data = array([(randint(1_000, 10_000), randint(-700, 700), randint(-700, 700), 1) for i in range(constants.BODIES)])
    cdef hand handler = hand.__new__(hand, np_data)
    cdef particle[::1,:,] particles = np.zeros((2000000, 1), dtype=object)  # if movement does not occur, thats because this is a single memory view, copy instead
    cdef npc.ndarray[object, ndim=2] push
    particles = array([handler.particles.copy()])
    cdef unsigned long long int c = 0
    with open('data.pickle', 'wb') as file:
        pickle.dump(None, file)

    try:
        if constants.OUTPUT:
            while 1:
                c+=1
                handler.move_timestep()
                particles = append(particles, [handler.particles.copy()], axis=1)
                with nogil:
                    printf("%I64u\r", c)
        else:
            while 1:
                handler.move_timestep()
                particles = append(particles, [handler.particles.copy()], axis=1)
    except BaseException as e:
        print(f'\n\nError: {e}')
    end = <double>(time.perf_counter())
    print(f'\nTime: {end-begin}\n')
    printf('\nConverting to objects...\n')
    push = np.copy(particles).reshape((particles.shape[1]/constants.BODIES, constants.BODIES))
    printf('\nDone!\n')
    return push
globals()['particles'] = run()