#cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=True, warn.undeclared=True
# distutils: language=c++
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION


# density = 3.95g/cm^3
from libc.stdlib cimport realloc, malloc, free
from libcpp.unordered_set cimport unordered_set as cset
from libcpp.vector cimport vector
from libcpp.cmath cimport sqrt, fma, sin, cos, cbrt
from cpython.exc cimport PyErr_CheckSignals
from libc.stdio cimport printf, puts
from . cimport constants_cy as constants
from random import randint, uniform
import time
ctypedef (double, double, double, double, double, double, double) dtuple



cdef extern from "<stdbool.h>" nogil:
    ctypedef bint _Bool
    ctypedef _Bool bool

cdef extern from * nogil:
    """
    #define __MSVCRT_VERSION__ 0x1935
    #define PI 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930382
    #define VOL_MUL 0.23873241463784300365332564505877154305168946861068467312150101608834519645133980263517070414937962893410926409013693705533936776917186797931695111609754975884385995040611361635961661959538796153307609
    #define GRAVITY_CONST (6.6743 * 10e-11)
    #define GRAVITY_CONST_D (6.6743 * 10e-11)*2
    #define C_CONST 23983396.64  // max speed
    #define C_CONST_D 299792458.0*299792458.0
    static inline double sqrt2(const float& n){
        static union {int i; float f;} u;
        u.i = 0x2035AD0C + (*(int*)&n >> 1);
        return (double)(n / u.f + u.f * 0.25f);
    }
    static inline double time_dilation(const double& mass, const double& dist){
        return sqrt2(1-((GRAVITY_CONST_D*mass)/(dist*C_CONST_D)));
    }  // 1.0370633164556336e+33

    static double inline __fastcall icbrt(const float& n){
        int i = *(int*)&n;
        i = 0x548c39cb - i*(0.333333333f);
        float y = *(float*) &i;
        y = y*(1.5015480449f - 0.534850249f*n*y*y*y);
        //y = y*(1.333333985f - 0.33333333f*n*y*y*y); // second iteration not necessary
        return (double)(1/y);
    }
    
    static double inline __fastcall rad(const double& n){
        double x;
        x = icbrt((n)*0.00006043858598426405155780396077437254254473151104067966408139266230084688517755438041396726687326066555293905420003466760894667538460047290615619015597406323008705315200154775097711813154313619279318382)*1.2599210498948731647672106072782283505702514647015079800819751121552996765139594837293965624362550941543102560356156652593990240406137372284591103042693552469606426166250009774745265654803068671854055;
        return x*x; // basically convert mass to volume & finds roche limit squared
        // 0.23873241463d, 0.00040816326d
    }


    """
    const bool unlikely(bool T) noexcept nogil
    const bool likely(bool T) noexcept nogil
    const double GRAVITY_CONST "GRAVITY_CONST"
    const double GRAVITY_CONST_D "GRAVITY_CONST_D"
    const double C_CONST "C_CONST"
    const double C_CONST_D "C_CONST_D"
    const double PI "PI"
    const double VOL_MUL "VOL_MUL"
    const double time_dilation(const double& mass, const double& dist) noexcept nogil
    const double rad(const double& n) noexcept nogil
    const double icbrt(const float& n) noexcept nogil
    const double sqrt2(const float& n) noexcept nogil

cdef inline dtuple rand_point() noexcept:
    cdef double x, y, theta, phi,z
    phi = uniform(0, PI)
    theta = uniform(0, 2*PI)
    x = 50_000_000*cos(theta)*sin(phi)
    y = 50_000_000*sin(theta)*sin(phi)
    z = 50_000_000*cos(phi)
    return uniform(1_000_000, 9_223_372_036_854_775_807)*10_000, x, y, z, uniform(-10, 10), uniform(-10, 10), uniform(-10, 10)

cdef struct particle_s:
    double mass
    double x
    double y
    double z
    double vx
    double vy
    double vz
    double r
    unsigned int hashed

ctypedef vector[(double, double, double, double)] vec3

cdef int move_particle(particle_s& self, particle_s*& merged, cset[int]& ignore, vec3& mlist, unsigned int& length) noexcept:
    '''Moves a particle through space based on the positions of others particles
    Parameters
    :self: the particle being moved
    :others: An iterable of Particle objects.
    Returns void'''
    '''Dist func: |(1/sin(θ))*base|'''
    if (ignore.contains(self.hashed)):
        return 0
    cdef int index = 0
    cdef double temp_force, temp, sqr_mag1, x, y, z, tx, ty, tz, mass, sqr_mag, time_d=1, time_temp=0
    cdef double net_f_x = 0
    cdef double net_f_y = 0
    cdef double net_f_z = 0
    cdef particle_s part
    for index in range(length):
        part = merged[index]
        if unlikely(self.hashed == part.hashed):  # ensure that we are not calculuting a particles own force
            continue
        x = part.x
        y = part.y
        z = part.z
        mass = part.mass
        tx = (x-self.x)
        ty = (y-self.y)
        tz = (z-self.z)
        temp = fma(tx, tx, fma(ty, ty, tz*tz))
        #temp = (tx*tx)+(ty*ty)+(tz*tz)# pythagorean theorem
        if (self.mass > mass):
            if (temp < (self.r)):
                
                self.mass += mass
                self.r = rad(self.mass)
                ignore.insert(part.hashed)
                continue
        sqr_mag = sqrt2(temp)  # apparently this should be fast enough
        sqr_mag1 = 1/sqr_mag
        temp_force = (GRAVITY_CONST*mass/temp)
        if temp_force > C_CONST:  # cap
            temp_force = C_CONST
        time_temp = time_dilation(mass, sqr_mag)  # time dilation
        if time_temp < time_d:time_d = time_temp
        net_f_x = fma(temp_force, tx*sqr_mag1, net_f_x)
        net_f_y = fma(temp_force, ty*sqr_mag1, net_f_y)
        net_f_z = fma(temp_force, tz*sqr_mag1, net_f_z)


    self.vx += net_f_x  # increase velocity according to gravity
    self.vy += net_f_y
    self.vz += net_f_z
    self.x += self.vx*time_d  # move according to velocity
    self.y += self.vy*time_d
    self.z += self.vz*time_d

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

    def __cinit__(Handler self, const vector[dtuple]& weights):
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        cdef unsigned int i
        self.length = constants.BODIES
        self.particles = <particle_s*>malloc((sizeof(particle_s)*weights.size()))
        cdef dtuple o
        for i in range(weights.size()):
            o = weights[i]
            self.particles[i] = particle_s(mass=o[0], x=o[1], y=o[2], z=o[3], vx=o[4], vy=o[5], vz=o[6], hashed=i, r=rad(o[0]))

    cdef vec3 move_timestep(Handler self) noexcept:
        '''Moves all the particles one frame.'''
        cdef int index, i
        cdef particle_s part
        cdef particle_s* merging = <particle_s*>malloc((sizeof(particle_s)*self.length))
        cdef vec3 merged_list
        cdef cset[int] ignore
        cdef unsigned int length = 0
        merged_list.reserve(self.length)
        for index in range(self.length):
            part = self.particles[index]
            i = move_particle(part, self.particles, ignore, merged_list, self.length)
            if likely(i):
                merging[length] = part
            length += i
            
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
    #    cdef double x, y, z, mass
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

cdef list[object] s() noexcept:
    cdef unsigned int i
    cdef float c, begin, end
    cdef vector[dtuple] data
    data.reserve(constants.BODIES)
    for i in range(constants.BODIES):
        data.push_back(rand_point())
    
    cdef Handler handler = Handler(data)
    data.clear()
    data.shrink_to_fit()
    cdef vector[vec3] particles
    particles.reserve(constants.N_FRAMES)
    c = 0.0
    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                particles.push_back(handler.move_timestep())
                c += 1.0
                PyErr_CheckSignals()

                    
                printf("%1.f\r", c)
        else:
            while 1:
                # running without printing timestep is faster than doing so
                particles.push_back(handler.move_timestep())
                i += 1
                if (i==100):
                    PyErr_CheckSignals()
                    i = 0
    except BaseException as e:
        end = (time.perf_counter())
        print(f'\n\nError: {e}')
    printf('\nTime: %f\n\n', <float>(end-begin))
    puts('\nConverting to objects...\n')
    #push = np.array(particles, dtype=np.double32)#.reshape((len(particles)/constants.BODIES, constants.BODIES, 2))

    puts('\nDone!\n')
    globals()['session'] = [(handler.particles[i].mass,  handler.particles[i].x,  handler.particles[i].y, handler.particles[i].z, handler.particles[i].vx, handler.particles[i].vy, handler.particles[i].vz) for i in range(handler.length)]
    
    return ([vector_2_list(particles[i]) for i in range(particles.size())])

cpdef public run():
    globals()['particles'] = s()
