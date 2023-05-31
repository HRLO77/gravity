# cython: wraparound=False
# cython: boundscheck=False
# cython: infer_types=True
# cython: language_level=3
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import math
import numpy as np
from . import constants_cy as constants
import numpy as np
from libc.math cimport sin, cos, atan2
np.ALLOW_THREADS = True

cdef class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    cdef public float x, direction, y, force
    cdef public int mass

    def __cinit__(self, int mass, float x, float y , float force = 0):
        self.mass = mass
        self.x = <float>x
        self.y = <float>y
        self.direction = 1.0
        self.force = <float>force
        
      
    cdef public float calculate_force(self, (float, float) position, float weight, ):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        cdef float posx = position[0]
        cdef float posy = position[1]
        cdef float f
        f = (math.dist((self.x, self.y), (posx, posy)))
        if f > 0:
            f = (constants.G*self.mass*weight)/f**2+(constants.SOFTEN)
            return f
        f = (constants.G*self.mass*weight)/1+(constants.SOFTEN)
        return f
        
      
    cdef public inline float calculate_direction(self, (float, float) position):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        return <float>(atan2((position[1])-self.y, (position[0])-self.x)/constants.RADIAN_DIV)
        
      
    cdef public void move(self, particle[:,] others):
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        # cdef np.ndarray[object, ndim=1] others_arr
        #cdef np.ndarray[long int, ndim=1] arange_others_arr
        #cdef np.ndarray[(float, float), ndim=2] calculations
        #cdef np.ndarray[float, ndim=1] Fx
        #cdef np.ndarray[float, ndim=1] Fy
        cdef particle[:,] others_arr
        cdef float[:,:] calculations
        cdef float[:,] Fx, Fy
        cdef float net_f_x, net_f_y, net_force, vx_current, vy_current, vx_net, vy_net, f_required_x, f_required_y, force_required, direction, f
        others_arr = np.array(others)
        arange_others_arr = range(others_arr.shape[0])
        calculations = np.array(sorted(((self.calculate_direction(position=(others_arr[p_index].x, others_arr[p_index].y))), self.calculate_force(position=(others_arr[p_index].x, others_arr[p_index].y), weight=others_arr[p_index].mass)) for p_index in arange_others_arr))
        # if type(others)==dict:
        #     calculations = sorted([(self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))] for p, w in others.items())  # calculate directions to face to, and the force of attraction
        # else:

        #     Fx, Fy = zip(*[(part.force*np.cos(part.direction, dtype=float), part.force*np.sin(part.direction, dtype=float)) for part in others])
        # print(Fx, Fy, [(part.force*np.cos(part.direction), part.force*np.sin(part.direction)) for part in others])
        # exit()
        a = []
        # max_d, max_f = calculations[0]
        
        f = self.force
        zipped = zip(*[(calculations[index][1]*cos(calculations[index][0]),calculations[index][1]*sin(calculations[index][0])) for index in arange_others_arr])
        Fx, Fy = np.array(zipped[0]), np.array(zipped[1])
        net_f_x = ((sum(Fx)))
        net_f_y = ((sum(Fy,)))
        net_force = (((net_f_x**2) + (net_f_y**2))**0.5)
        # print(net_force, 'net')
        vx_current = self.force * cos(self.direction,)
        vy_current = self.force * sin(self.direction,)
        vx_net = -vx_current + (net_f_x / self.mass)
        vy_net = -vy_current + (net_f_y / self.mass)
        # vx_required = ((vx_current**2)+(vy_current**2))**0.5
        f_required_x = self.mass*vx_net
        f_required_y = self.mass*vy_net
        force_required = ((f_required_x**2)+(f_required_y**2))**0.5
        direction = atan2(net_f_y, net_f_x)
        
        # print(f ** 2, net_force, force_required)

            # p = f*f
        # p = float(f'{f}'.split('e')[0][:10])
        
        # exit()
        # print(p)
        if f>0:f = (((net_force / (f)))-force_required)
        else:f = (net_force-force_required)

        # print(f, force_required, direction)
        # exit()
        # print(f, direction)
        self.direction = <float>direction
        # try:
        self.force = <float>(f)
        # except ValueError as e:
            # print(str(e))
        # print(prev, 'test', f, net_force, factor_to_move, 'test', (net_f_x*net_f_x) + (net_f_y*net_f_y), net_f_x, net_f_y)
            # exit()
        return

    
    cdef public void goto(self):
        '''Moves X and Y position based on a timestep, current direction and force.'''
        cdef float far
        cdef float move_x
        cdef float move_y
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