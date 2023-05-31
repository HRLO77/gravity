# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
# cython: boundscheck=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import math
from cython.parallel import prange
import numpy as np
from . import constants_cy as constants
from . import classes_cy as classes
cimport numpy as np
np.ALLOW_THREADS = True

cdef class handler:
    '''A class wrapper to handle multiple pygame classes.particles, wrapping particles.'''
    cdef object[:,] particles

    def __cinit__(self, int[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = np.array((classes.particle.__new__(classes.particle, <int>np.round(mass), <float>x, <float>y, <float>force) for mass, x, y, force in weights))
        
    
    cdef object[:,] move_timestep(self):
        '''Moves all the particles one time step.'''
        # print('running')
        # print(self.particles)
        cdef unsigned long long int length = self.particle.shape[0]
        cdef object[:,] parts = self.particles.copy()
        cdef object[:,] array
        for index in range(length):
            array = self.parts[:index]+self.parts[index+1:]
            parts[index].move(array)  # perform calculations
            parts[index].goto()  # move accordingly
            # comp_arr = arr[:ind1]+arr[ind1+1:]
            # p = [*sorted(((comp_arr[p].particle, math.dist((arr[ind1].particle.x, arr[ind1].particle.y), (comp_arr[p].particle.x, comp_arr[p].particle.y))) for p in ranged[:length-1]), key=lambda x: x[-1])]
            # asp = []
            # if any(part[1] < limit for part in p):

            #     ignore_p = np.array((p.pop(index) for part in p if part[1] < limit))
            #     index+=1
            #     aranged_ignore_p = np.arange(ignore_p.shape[0])
            #     mass, x, y, force = zip(*((ignore_p[part_ind][0].mass, ignore_p[part_ind][0].x, ignore_p[part_ind][0].y, ignore_p[part_ind][0].force) for part_ind in aranged_ignore_p))
            #     mass, x, y, force = np.sum(mass), direction_func(x), direction_func(y), np.sum(force)
            #     asp = [classes.particle(mass, x, y, force)]
            # p = np.array(p[part][0] for part in ranged[:length-1])
            # p = p[first:]

            # associate = tuple()
            # ask = set()
            # for part in p[last::skip]:
                
            #     closest = np.array(sorted(p, key=lambda x: math.dist((part.x, part.y), (x.x, x.y))))
            #     kp = [i for i in closest[:take_part] if not i in ask]
            #     associate, ask = (*associate, part, *kp), {*ask, part, *kp}
            # cp = 0
            # associate = np.array(associate)
            # for n in associate[::take_part]:
            #     mass, x, y, force = zip(*((p.mass, p.x, p.y, p.force) for p in associate[cp*take_part:(cp+1)*take_part]))
            #     mass, x, y, force = np.sum(mass), direction_func(x), direction_func(y), np.sum(force)
            #     asp += [classes.particle(mass, x, y, force)]
                # cp+=1
            # ind = [1, 0]
            # cur = 0
            # a = []
            # while True:
            #     spr = p[cur:cur+ind[0]]
            #     if spr==[]:
            #         break
            #     dat = [*zip(*[(part.particle.mass, part.particle.x, part.particle.y, part.particle.force) for part in spr])]
                
            #     mass, x, y, force = np.sum(dat[0]), np.mean(dat[1]), np.mean(dat[2]), np.sum(dat[3])
            #     a += [classes.particle(mass, x, y, force)]
            #     cur += ind[0]
            #     ind[-1] += 1
            #     if ind[-1] >= 15:
            #         ind[0] += 1
            #         ind[-1] = 0
            # print(fp + asp) 
            
            # exit()
            self.particles = parts
            return parts
    
    
    def __eq__(self, __value):
        return __value.particles == self.particles
    
    
    def __hash__(self):
        return hash(self.particles)