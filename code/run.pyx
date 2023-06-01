# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
# cython: boundscheck=False
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import pickle, random
import cython
cimport numpy as npc
from . cimport classes_cy as classes
from . cimport constants_cy as constants
from . cimport pygame_classes_cy as pygame_classes
from . import classes_cy as classes
from . import constants_cy as constants
from . import pygame_classes_cy as pygame_classes
import time
import numpy as np
from numpy.random import randint
cdef unsigned int run():
    cdef double begin, end
    begin = <double>(time.perf_counter())
    #aranged = range(constants.BODIES)
    cdef int[:,:,] np_data = np.array([(randint(1_000, 10_000), randint(-700, 700), randint(-700, 700), 1) for i in range(constants.BODIES)])
    cdef object handler = pygame_classes.handler.__new__(pygame_classes.handler, np_data)
    cdef list particles = [handler.particles]  # if movement does not occur, thats because this is a single memory view, copy instead
    #cdef object[:,] dat = handler.particles
    with open('data.pickle', 'wb') as file:
        pickle.dump(None, file)
    try:
        while True:
            handler.move_timestep()
            particles += [handler.particles]
    except BaseException as e:
        print(f'Error: {e}')

    print('Dumping data...')
    with open('data.pickle', 'wb') as file:
        pickle.dump(<object>particles, file)
    print('Done!')
    end = <double>(time.perf_counter())

    print(f'Time: {end-begin}')
    return <unsigned int>len(particles)
globals()['particles'] = run()