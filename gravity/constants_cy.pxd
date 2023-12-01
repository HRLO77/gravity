#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=False, warn.undeclared=True
# distutils: language=c

cdef public int BODIES
cdef public bint OUTPUT
cdef public float TIMESTEP
cdef public bint LOAD_DATA
cdef public unsigned int N_FRAMES