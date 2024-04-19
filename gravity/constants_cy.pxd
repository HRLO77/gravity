#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=False, warn.undeclared=True
# distutils: language=c
import random

cdef public unsigned int BODIES
cdef public bint OUTPUT
#cdef public float TIMESTEP
cdef public bint LOAD_DATA
cdef public unsigned int N_FRAMES
cdef public unsigned int START_MODE
cdef public double X_LIM
cdef public double Y_LIM
cdef public double Z_LIM
cdef public bint RAND_SPIN
cdef public double RAND_SPEED
cdef public double MAX_MASS