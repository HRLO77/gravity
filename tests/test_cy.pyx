#cython: language_level=3, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False
# distutils: language=c

from libc.stdlib cimport malloc, free, realloc
from libc.stdio cimport printf
import pickle
cdef list thing = []
cdef float* array = <float*>malloc(12)
cdef int i
cdef NULL* arr = <NULL*>malloc(sizeof(NULL)*12)
arr[0] = NULL
array[0] = 1
array[1] = 2
array[2] = 3
printf('opening\n')

for i in range(-10000, 10000):
    thing.append(array[i])
printf('running\n')
pickle.dump(thing, open('./test.pickle', 'wb'))