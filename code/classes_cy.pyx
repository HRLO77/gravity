# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
import math
import constants_cy as constants
cimport constants_cy as constants
import pygame_classes_cy as pygame_classes
cimport pygame_classes_cy as pygame_classes
cimport classes_cy as classes
import numpy as np
cimport numpy as np
from libc.math cimport sin, cos, atan2                                        
np.ALLOW_THREADS = True
# class unit:
#     '''Represents a single unit in spatial co-ordinate plane, cannot be moved through higher dimensions.'''

#     def __init__(self, mass: float, x: int, y: int) -> None:
#         self.mass = mass
#         self.x = x
#         self.y = y
        

#     def calculate_force(self, other=None, weight: float | None=None, position=None):
#         '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
#         assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
#         if isinstance(other, self.__class__):
#             f = (math.dist((other.x, self.y), (other.x, self.y)))
#             if f > 0:
#                 return (constants.G*self.mass*other.mass)/f**2+(f*constants.SOFTEN)
#             return (constants.G*self.mass*other.mass)/1+(1*constants.SOFTEN)
#         else:
#             f = (math.dist((self.x, self.y), ((position[0]), (position[1]))))
#             if f > 0:
#                 return (constants.G*self.mass*weight)/f**2+(f*constants.SOFTEN)
#             return (constants.G*self.mass*weight)/1+(1*constants.SOFTEN)
    

#     def calculate_direction(self, other=None, position=None):
#         '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
#         assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
#         assert isinstance(position, tuple) or position==None
#         if isinstance(other, self.__class__):
#             t = np.arctan2(self.y-other.y, self.x-other.x)
#             # slope = math.tan(t)
#             return t/constants.RADIAN_DIV
#         else:
#             t = np.arctan2((position[1])-self.y, (position[0])-self.x)
#             # slope = math.tan(t)
#             return t/constants.RADIAN_DIV

cdef class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    cdef float x, direction, y, force
    cdef int mass
    

    def __cinit__(self, int mass, float x, float y , float force = 0):
        self.mass = mass
        self.x = <float>x
        self.y = <float>y
        self.direction = 1.0
        self.force = <float>force
        
      
    cdef float calculate_force(self, (float, float) position, float weight, ):
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
        
      
    cdef float calculate_direction(self, (float, float) position):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        cdef float posx = position[0]
        cdef float posy = position[1]
        cdef float t
        # slope = math.tan(t)
        t = <float>(atan2((posy)-self.y, (posx)-self.x)/constants.RADIAN_DIV)
        return t
        
      
    cdef void move(self, particle[:,] others):
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

    
    cdef void goto(self):
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