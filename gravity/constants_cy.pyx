#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=False, warn.undeclared=True
# distutils: language=c

cdef public unsigned int BODIES = int(input("Enter bodies: "))
cdef public bint OUTPUT = bool(int(input('Print progress?: ')))
cdef public float TIMESTEP = float(input('Timestep (0.001/1000 reference): '))
cdef public unsigned int N_FRAMES = int(input('How many frames should be reserved at start?: '))
cdef public bint LOAD_DATA = bool(int(input('Load data from previous session?: ')))
__all__ = globals()