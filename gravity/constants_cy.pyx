#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=False, warn.undeclared=True
# distutils: language=c
import random

cdef public unsigned int BODIES = int(input("Enter N-bodies: "))
cdef public bint OUTPUT = bool(int(input('Print progress?: ')))
#cdef public float TIMESTEP = float(input('Timestep (0.001/1000 reference): '))
cdef public unsigned int N_FRAMES = int(input('How many frames should be reserved at start?: '))
cdef public unsigned int START_MODE = 0
cdef public double X_LIM = random.uniform(0, 1_350_000_000) # 400M good for disks/spheres
cdef public double Y_LIM = random.uniform(0, 1_350_000_000)
cdef public double Z_LIM = random.uniform(0, 1_350_000_000)
cdef public bint RAND_SPIN = True
cdef public double RAND_SPEED = 75_000
cdef public double MAX_MASS = 9_223_372_036_854_775_807

string = input('Max mass limit? (Press enter to default MAX): ')
if string!='':
    MAX_MASS = int(string)

if (bool(int(input('Pick start mode? [1/0]: ')))):
    START_MODE = int(input('Random [0] (makes custom bounds), Cube [1], Sphere [2], Sphere with spin [3], Disk [4], Disk with spin [5]: '))
    if START_MODE > 5 or (START_MODE<0):
        print('Invalid mode, defaulting to Random [0]...')
        START_MODE=0
    else:
        if (bool(int(input('Use random space limits? [1/0]: ')))):
            if START_MODE>3:
                Z_LIM = random.uniform(2_000_000, 20_000_000) # cuz its a disk
        else:
            X_LIM = abs(int(input('Enter X_LIM: ')))
            Y_LIM = abs(int(input('Enter Y_LIM: ')))
            Z_LIM = abs(int(input('Enter Z_LIM: ')))
    if (START_MODE!=3 and START_MODE!=5):
        RAND_SPIN = (bool(int(input('Initialize random start velocities? [1/0]: '))))
    if RAND_SPIN:
        string = input('Max initialized velocity? (Press Enter to default 75k): ')  # 10k good for disks
        if string!='':
            RAND_SPEED = int(string)
            RAND_SPIN = False
        else:
            RAND_SPIN=True
__all__ = globals()