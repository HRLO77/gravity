#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=True, warn.undeclared=True
# distutils: language=c++
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION


# density = 3.5g/cm^3
from libc.stdlib cimport realloc, malloc, free
from libcpp.unordered_set cimport unordered_set as cset
from libcpp.vector cimport vector
from cpython.exc cimport PyErr_CheckSignals
cimport cython
cimport numpy as npc
from libc.stdio cimport printf, puts
import pickle
from . cimport constants_cy as constants
from numpy.random import randint
import time
npc.import_array()
cdef extern from *:
    """
    #define GRAVITY_CONST (float)(6.6743f * 10e-11f)  // modified gravity
    static float inline __fastcall cbrt(float n, unsigned int e){
        float l=0, r=n*0.5f, m=(r+l)*0.5f;
        unsigned int i;
        for (i=0;i<e;++i){ // if difference between m^3 and n is not satisfactory
            m=(r+l)*0.5f;
            if(m*m*m<n) // if m^3 < n, then the root is definitely greater then m, so we move the left border
                l=m;
            else // otherwise, move the right border
                r=m;
        }
        return m;
    }
    static float inline __fastcall rad(float n, unsigned int e){
        return cbrt((n)*0.06820926132509800104380732715964901230048270531733847803471457602524148470038280075290591547125132255260264688289626773009696221976339085123341460459929993109824570011603246181703331988439656043802174f, e); // basically convert mass to volume & finds radius
        // 0.23873241463f, 0.00040816326f
    }


    """
    const bint unlikely(bint T) noexcept nogil
    const bint likely(bint T) noexcept nogil
    const float GRAVITY_CONST "GRAVITY_CONST"
    const float rad(float n, unsigned int e) noexcept nogil
    const float cbrt(float n, unsigned int e) noexcept nogil


import numpy as np
from numpy import array
import random
cdef struct particle_s:
    float mass
    float x
    float y
    float z
    float vx
    float vy
    float vz
    float r
    unsigned int hashed

ctypedef vector[(float, float, float, float)] vec3


cdef bint begin_force = True

cdef int move_particle(particle_s& self, particle_s*& merged, cset[int]& ignore, vec3& mlist, unsigned int& length) noexcept:
    '''Moves a particle through space based on the positions of others particles
    Parameters
    :self: the particle being moved
    :others: An iterable of Particle objects.
    Returns void'''
    '''Dist func: |(1/sin(θ))*base|'''
    if ignore.contains(self.hashed):
        return 0
    cdef int index
    cdef float temp_force=0, temp=0, x=0, y=0, z=0, tx=0, ty=0, tz=0, mass=0, orad=0, limit=0
    cdef float net_f_x = 0
    cdef float net_f_y = 0
    cdef float net_f_z = 0
    cdef particle_s part
    cdef bint merging = False
    for index in range(length):
        part = merged[index]
        if unlikely(self.hashed == part.hashed):  # ensure that we are not calculuting a particles own force
            continue
        x = part.x
        y = part.y
        z = part.z
        mass = part.mass
        orad = part.r
        tx = (x-self.x)
        ty = (y-self.y)
        tz = (z-self.z)
        temp = (tx*tx)+(ty*ty)+(tz*tz)# pythagorean theorem
        if (self.mass > mass):
            limit = (orad*cbrt(2*(self.mass/mass), 35))
            if (temp < (limit*limit)):
                merging = True
            
        #temp_force = self.calculate_force(temp, mass)  # calculate the attraction
        temp_force = (mass*GRAVITY_CONST)/temp
        net_f_x += (tx)*temp_force  # spread it accross the two dimensions
        net_f_y += (ty)*temp_force
        net_f_z += (tz)*temp_force
        if (merging):
            self.mass += mass
            self.x = (x+self.x)*0.5
            self.y = (y+self.y)*0.5
            self.z = (z+self.z)*0.5
            ignore.insert(part.hashed)
            self.r = rad(self.mass, 35)
            
    self.vx += net_f_x  # increase velocity according to gravity
    self.vy += net_f_y
    self.vz += net_f_z
    self.x += self.vx  # move according to velocity
    self.y += self.vy
    self.z += self.vz

    mlist.push_back((self.x, self.y, self.z, self.mass))
    return 1

cdef inline list vector_2_list(vec3& vec,) noexcept:
    cdef list l = []
    cdef int i
    for i in range(vec.size()):
        l.append(vec[i])
    return l



cdef class Handler:
    '''A class wrapper to handle multiple Particle objects easily.'''

    cdef particle_s* particles 
    cdef unsigned int length

    def __cinit__(Handler self, const float[:,:,] weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        cdef int i
        self.length = constants.BODIES
        self.particles = <particle_s*>malloc((sizeof(particle_s)*len(weights)))
        cdef const float[:,] o
        for i in range(weights.shape[0]):
            o = weights[i]
            self.particles[i] = particle_s(mass=o[0], x=o[1], y=o[2], z=o[3], vx=o[4], vy=o[5], vz=o[6], hashed=i, r=rad(o[0], 35))

    cdef vec3 move_timestep(Handler self) noexcept:
        '''Moves all the particles one frame.'''
        cdef int index=0, i=0
        cdef particle_s part
        cdef particle_s* merging = <particle_s*>malloc((sizeof(particle_s)*self.length))
        cdef vec3 merged_list
        cdef cset[int] ignore
        cdef int length = 0
        merged_list.reserve(self.length)
        for index in range(self.length):
            part = self.particles[index]
            i = move_particle(part, self.particles, ignore, merged_list, self.length)
            if (i==1):
                merging[length] = part
            length += 1
            
        #merged = array(merged_list)
        if (length!=self.length):
            merging = <particle_s*>realloc(merging, (sizeof(particle_s)*length))
        free(self.particles)
        self.particles = merging
        self.length = length
        return merged_list

    #cdef vec3 get(Handler self) noexcept:
    #    '''Returns the position of all particles in the current frame.'''
    #    cdef int index
    #    cdef float x, y, z, mass
    #    cdef particle_s part
    #    cdef vec3 l
    #    l.reserve(self.length)
    #    for index in range(self.length):
    #        part = self.particles[index]
    #        x = part.x
    #        y = part.y
    #        z = part.z
    #        mass = part.mass
    #        l.push_back((x, y, z, mass))
    #    return l

    def __dealloc__(self,):
        free(self.particles)
        self.length = 0

cdef list[object] s():
    cdef float[:,:,] np_data
    if not constants.LOAD_DATA:
        # this line creates the particles, you can change the range of where they start, their mass, and beginning velocity to whatever you wish.
        np_data = array(
            [
                (randint(1_000_000, 2_147_483_647)*150000000, randint(-1_000_000_000, 1_000_000_000), randint(-1_000_000_000, 1_000_000_000), randint(-1_000_000_000, 1_000_000_000), randint(-10, 10), randint(-10, 10), randint(-10, 10))
                for i in range(constants.BODIES)
            ],
            dtype = np.float32,
        )
    else:
        # this line loads up the last frame from data.pickle if you want to continue a simulation (very useful if you are running low on memory)
        with open('data.pickle', 'rb') as f:
            np_data = pickle.load(f)[1]
    cdef Handler handler = Handler(np_data)
    np_data = np.array([[1], [1]], dtype=np.float32)
    cdef vector[vec3] particles
    particles.reserve(constants.N_FRAMES)
    cdef float c, begin, end
    cdef unsigned int i, j, k
    c = 0.0

    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                particles.push_back(handler.move_timestep())
                begin_force = False
                c += 1.0
                printf("%1.f\r", c)
                
                PyErr_CheckSignals()
        else:
            while 1:
                # running without printing timestep is faster than doing so
                particles.push_back(handler.move_timestep())
                begin_force = False
                PyErr_CheckSignals()
    except BaseException as e:
        end = (time.perf_counter())
        print(f'\n\nError: {e}')
    printf('\nTime: %f\n\n', <float>(end-begin))
    puts('\nConverting to objects...\n')
    #push = np.array(particles, dtype=np.float32)#.reshape((len(particles)/constants.BODIES, constants.BODIES, 2))

    puts('\nDone!\n')
    globals()['session'] = np.array([(handler.particles[i].mass,  handler.particles[i].x,  handler.particles[i].y, handler.particles[i].z, handler.particles[i].vx, handler.particles[i].vy, handler.particles[i].vz) for i in range(handler.length)], dtype=np.float32)
    
    return ([vector_2_list(particles[i]) for i in range(particles.size())])

cpdef public run():
    globals()['particles'] = s()
