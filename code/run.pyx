# cython: wraparound=False
# cython: infer_types=True
# cython: language_level=3
import pickle, random
cimport numpy as np
from . cimport classes_cy as classes
from . cimport constants_cy as constants
from . cimport pygame_classes_cy as pygame_classes
import time
import numpy as np
cdef float begin, end
begin = <float>(time.perf_counter())
aranged = range(constants.BODIES)

cdef pygame_classes.handler handler = pygame_classes.handler([(np.random.randint(1_000, 20_000), np.random.randint(-700, 700), np.random.randint(-700, 700), 1) for i in aranged])

cdef classes.particle[:,:,] particles
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
