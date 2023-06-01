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
import numpy as np
from . cimport constants_cy as constants
cimport numpy as npc
from numpy import array
import cython
cimport cython
from libc.math cimport sin, cos, atan2
np.ALLOW_THREADS = True

@cython.auto_pickle(True)
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
        
      
    cdef public double calculate_force(self, (double, double) position, unsigned int weight) except -1.0:
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        cdef double posx = position[0]
        cdef double posy = position[1]
        cdef double f
        f = (math.dist((self.x, self.y), (posx, posy)))
        if f > 0:
            f = (constants.G*self.mass*weight)/f**2+(constants.SOFTEN)
            return f
        f = (constants.G*self.mass*weight)/1+(constants.SOFTEN)
        return <double>f
        
      
    cdef public double calculate_direction(self, (double, double) position) except -1.0:
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        return <double>(atan2((position[1])-self.y, (position[0])-self.x)/constants.RADIAN_DIV)
        
      
    cpdef public void move(self, particle[:,] others) except *:
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        cdef double[:,:,] zipped, calculations
        cdef unsigned int index
        #cdef double[:,] Fx, Fy
        #cdef double net_f_x, net_f_y, net_force, vx_current, vy_current, vx_net, vy_net, f_required_x, f_required_y, force_required, direction, f, temp_dir, temp_force
        cdef double net_f_x, net_f_y, net_force, force_required, direction, f
        arange_others = range(others.shape[0])
        calculations = array([(self.calculate_direction((others[index].x, others[index].y)), self.calculate_force((others[index].x, others[index].y), others[index].mass)) for index in arange_others])
        f = self.force
        zipped = array([*zip(*[(calculations[index][1]*cos(calculations[index][0]),calculations[index][1]*sin(calculations[index][0])) for index in arange_others])])
        
        #Fx, Fy = array(zipped[0]), array(zipped[1])
        
        net_f_x = ((np.sum(zipped[0])))
        net_f_y = ((np.sum(zipped[1])))

        net_force = (((net_f_x**2) + (net_f_y**2))**0.5)

        #vx_current = self.force * cos(self.direction,)
        #vy_current = self.force * sin(self.direction,)

        #vx_net = -(self.force * cos(self.direction,)) + (net_f_x / self.mass)
        #vy_net = -(self.force * cos(self.direction,)) + (net_f_y / self.mass)

        #f_required_x = self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass))
        #f_required_y = self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass))
        #force_required = (((self.mass*(-(self.force * cos(self.direction,)) + (net_f_x / self.mass)))**2)+((self.mass*(-(self.force * cos(self.direction,)) + (net_f_y / self.mass)))**2))**0.5
        
        # README: The commented out lines above are for determining velocity required to bypass pulls, if the energy of the system does not obey the laws of thermodynamics, fix HERE!

        direction = atan2(net_f_y, net_f_x)
    

        if f>0:f = (((net_force / (f))))
        else:f = (net_force) # subtract required force here

        self.direction = direction
        self.force = f
        self.goto()
        return

    
    cdef public void goto(self) except *:
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
    
    
    def __eq__(self, object __value ):
        return (self.force, self.x, self.y, self.mass, self.direction) == (__value.force, __value.x, __value.y, __value.mass, __value.direction)
    
    
    def __hash__(self):
        return hash((self.force, self.x, self.y, self.mass, self.direction))

    def __reduce__(self):
        return (self.__class__.__new__, (self.mass, self.x, self.y, self.force))