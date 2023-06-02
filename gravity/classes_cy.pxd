# cython: boundscheck=False
# cython: infer_types=True
# cython: language_level=3
import math
import numpy as np
cimport numpy as np
np.ALLOW_THREADS = True

#cdef class particle:
#     '''Represents a single particle, can be moved through higher dimensions.'''
#     cdef public:
#         float x, y, direction, force
#         int mass
        
#     cdef inline float calculate_force(self, (float, float) position, float weight, ):
#         ...

#     cdef inline float calculate_direction(self, (float, float) position):
#         ...

#     cdef inline void move(self, particle[:,] others):
#         ...

#     cdef inline void goto(self):
#         ...
