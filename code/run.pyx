# cython: language_level=3
# distutils: language=c
# cython: infer_types=False
# cython: wrap_around=False
# cython: bounds_check=False
# cython: cdivision=True
# cython: overflow_check=False
# cython: none_check=False
# cython: initialized_check=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import pickle
from numpy import array, append
from . cimport constants_cy as constants
import time
from numpy.random import randint
from libc.stdio cimport printf
cimport numpy as npc
import numpy as np
cimport cython
from libc.math cimport sin, cos, atan2, fabs
np.ALLOW_THREADS = True

cdef class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    cdef public double x, y
    cdef double vx, vy
    cdef unsigned long long int mass

    def __cinit__(self, int mass, double x, double y, double vx = 0.0, double vy = 0.0):
        self.mass = mass
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        
      
    cdef inline double calculate_force(self, double dist, unsigned long long int weight) except -1.0:
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        return (constants.G*self.mass*weight)/((dist))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)
      
    cdef void move(self, particle[:,] others) except *:
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        '''Dist func: |(1/sin(θ))*base|'''
        #cdef double[:,:,] zipped, calculations
        cdef unsigned long long int index
        #cdef double[:,] Fx, Fy
        #cdef double net_f_x, net_f_y, net_force, vx_current, vy_current, vx_net, vy_net, f_required_x, f_required_y, force_required, direction, f, temp_dir, temp_force
        cdef double net_f_x, net_f_y, temp_dir, temp_force, to_atan, temp, x, y
        cdef unsigned long long int mass
        net_f_x = 0
        net_f_y = 0
        cdef particle part
        #calculations = array([(self.calculate_direction((others[index].x, others[index].y)), self.calculate_force((others[index].x, others[index].y), others[index].mass)) for index in arange_others])
        #zipped = array([*zip(*[array([self.calculate_force((others[index].x, others[index].y), others[index].mass)]*2)*self.trig_put(self.calculate_direction((others[index].x, others[index].y))) for index in arange_others])])
        for index in range(len(others)):
            part = others[index]
            x = part.x
            y = part.y
            mass = part.mass
            #temp_dir = self.calculate_direction((x, y))
            temp_dir = (atan2(y-self.y, x-self.x)*constants.RADIAN_DIV)
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
        return

    
    # cdef inline void goto(self) except *:
    #     '''Moves X and Y position based on a timestep, current direction and force.'''
    #     cdef double far
    #     cdef double move_x
    #     cdef double move_y
    #     far = self.direction/constants.RADIAN_DIV
    #     #if constants.DISSIPATE:self.force = self.force-((self.force*0.001 if not(self.force==np.nan or self.force==0) else 0))  # attempted reality :(
    #     move_x = (cos(far,))
    #     move_y = (sin(far,))
    #     self.x += move_x
    #     self.y += move_y
    #     if self.x >= constants.X_SUB:
    #         self.x = -constants.X_SUB
    #     elif self.x <= -constants.X_SUB:
    #         self.x = constants.X_SUB
    #     if self.y >= constants.Y_SUB:
    #         self.y = -constants.Y_SUB
    #     elif self.y <= -constants.Y_SUB:
    #         self.y = constants.Y_SUB
    #     return



@cython.freelist(8192)
cdef class hand:
    '''A class wrapper to handle multiple pygame classes.particles, wrapping particles.'''
    cdef particle[:,] particles

    def __cinit__(self, const int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = array([particle( np.round(mass), x, y, vx, vy) for mass, x, y, vx, vy in weights])
    
    cdef inline void move_timestep(self) except *:
        '''Moves all the particles one time step.'''
        cdef unsigned long long int length = len(self.particles)
        cdef unsigned long long int index
        #cdef object[:,] array
        for index in range(length):
            #array = np.delete(self.particles, index)
            self.particles[index].move(np.delete(self.particles, index))  # perform calculations and move accordingly
    

cdef npc.ndarray[double, ndim=3] run() except *:
    cdef double begin, end
    begin = (time.perf_counter())
    #aranged = range(constants.BODIES)
    cdef const int[:,:,] np_data = array([(randint(10_000, 100_000), randint(-700, 700), randint(-700, 700), randint(-1, 1), randint(-1, 1)) for i in range(constants.BODIES)])
    cdef hand handler = hand(np_data)
    cdef particle[:,:,] particles # if movement does not occur, thats because this is a single memory view, copy instead
    cdef npc.ndarray[double, ndim=3] push
    particles = np.array([handler.particles.copy()])
    cdef unsigned long long int c
    c=0
    with open('data.pickle', 'wb') as file:
        pickle.dump(None, file)
    try:
        
        if constants.OUTPUT:
            while 1:
                c+=1
                handler.move_timestep()
                particles = append(particles,[handler.particles], axis=1)
                printf("%I64u\r", c)
        else:
            while 1:
                handler.move_timestep()
                particles = append(particles,[handler.particles], axis=1)
    except BaseException as e:
        print(f'\n\nError: {e}')
    end = (time.perf_counter())
    print(f'\nTime: {end-begin}\n')
    printf('\nConverting to objects...\n')
    push = np.copy([[(part.x, part.y) for part in particles[0]]]).reshape((len(particles[0])/constants.BODIES, constants.BODIES, 2))
    printf('\nDone!\n')
    return push
globals()['particles'] = run()