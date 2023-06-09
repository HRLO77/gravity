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


# this is an older version of the run.pyx file that imports classes_cy.pyx, pygame_classes_cy.pyx and constants_cy.pyx instead of having it in one file, which is slower.
import pickle, random
import cython
cimport numpy as npc
from numpy import array, append
from . import classes_cy as classes
from . cimport constants_cy as constants
from . import pygame_classes_cy as pygame_classes
import time
import numpy as np
from numpy.random import randint
from libc.stdio cimport printf

cdef unsigned int run():
    cdef double begin, end
    begin = <double>(time.perf_counter())
    #aranged = range(constants.BODIES)
    cdef int[:,:,] np_data = array([(randint(1_000, 10_000), randint(-700, 700), randint(-700, 700), 1) for i in range(constants.BODIES)])
    cdef object handler = pygame_classes.handler.__new__(pygame_classes.handler, np_data)
    cdef object[::1,:,] particles = np.zeros((2000000, 1), dtype=object)  # if movement does not occur, thats because this is a single memory view, copy instead
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
    printf('\nDumping data...')
    with open('data.pickle', 'wb') as file:
        push = np.copy(particles).reshape((particles.shape[1]/constants.BODIES, constants.BODIES))
        pickle.dump(push, file)
    printf('\nDone!\n')
    return <unsigned int>len(push)
globals()['particles'] = run()