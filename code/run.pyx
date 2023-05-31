# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
# cython: boundscheck=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import pickle, random
import cython
cimport numpy as np
from . cimport classes_cy as classes
from . cimport constants_cy as constants
from . cimport pygame_classes_cy as pygame_classes
from . import classes_cy as classes
from . import constants_cy as constants
from . import pygame_classes_cy as pygame_classes
import time
import numpy as np
from numpy.random import randint
cdef float begin, end
begin = <float>(time.perf_counter())
#aranged = range(constants.BODIES)
cdef int[:,:,] np_data = np.array([(randint(1_000, 10_000), randint(-700, 700), randint(-700, 700), 1) for i in range(constants.BODIES)])
cdef object handler = pygame_classes.handler.__new__(pygame_classes.handler, np_data)

cdef object[:,:,] particles
particles += [handler.particles]
with open('data.pickle', 'wb') as file:
    pickle.dump(None, file)
try:
    while True:
        particles += [handler.move_timestep()]
except BaseException as e:
    print(f'Error: {e}')

with open('data.pickle', 'wb') as file:
    pickle.dump(particles, file)

end = <float>(time.perf_counter())

print(f'Time: {end-begin}')
