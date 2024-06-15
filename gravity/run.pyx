# cython: language_level=3, binding=False, infer_types=False, wraparound=False, boundscheck=False, cdivision=True, overflowcheck=False, overflowcheck.fold=False, nonecheck=False, initializedcheck=False, always_allow_keywords=False, c_api_binop_methods=True, warn.undeclared=True
# distutils: language=c++
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION


# density = 3.95g/cm^3
# assume all bodies are perfect spheres, bodies immediately consume their ring systems, have same densities, exist in 3d euclidean space
from libc.stdlib cimport realloc, malloc, free
from libcpp.unordered_set cimport unordered_set as cset
from libcpp.vector cimport vector
from libcpp.cmath cimport sqrt, fma, sin, cos, cbrt
from cpython.exc cimport PyErr_CheckSignals
from libc.stdio cimport printf, puts
from . cimport constants_cy as constants
from .constants_cy cimport X_LIM, Y_LIM, Z_LIM, RAND_SPEED
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

    static double inline __fastcall icbrt(const float& n){
        int i = *(int*)&n;
        i = 0x548c39cb - i*(0.333333333f);
        float y = *(float*) &i;
        y = y*(1.5015480449f - 0.534850249f*n*y*y*y);
        //y = y*(1.333333985f - 0.33333333f*n*y*y*y); // second iteration not necessary
        return (double)(1/y);
    }

    static inline double speed_dilation(const double& speed){
        return std::sqrt(1-((speed)/C_CONST_D));
    }

    static inline double time_dilation(const double& mass, const double& dist){
        return std::sqrt(1-((GRAVITY_CONST_D*mass)/(dist*C_CONST_D)));
    }  // 1.0370633164556336e+33

    // rigid rad    

    static double inline __fastcall rad(const double& n){
        const double x = 2.423*std::cbrt(n*0.00006043858598426405155780396077437254254473151104067966408139266230084688517755438041396726687326066555293905420); // assume the densities are the same
        return x*x;
    }


    static double inline __fastcall rad1(const double& n){
        const double x = std::cbrt((n)*0.000060438585984264051557803960774372542544731511040679664081392662300846885177554380413967266873260665552939054200034667608946675384600472906156190155974063230087053152001547)*1.2599210498948731647672106072782283505702514647015079800819751121552996765139594837293965624362550941543102560356156652593990240406137372284591103042693552469606;
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
    const double sqrt2(const float& n, const float& x) noexcept nogil
    const double speed_dilation(const double& speed) noexcept nogil

cdef dtuple rand_point(const bool clockwise) noexcept:
    cdef double x, y, theta, phi,z, tx=0, ty=0, tz=0
    if ((constants.START_MODE==2) or (constants.START_MODE==3)): # sphere with/out spin
        phi = uniform(0, PI)
        theta = uniform(0, 2*PI)
        x = uniform(0, X_LIM)*cos(theta)*sin(phi)
        y = uniform(0, Y_LIM)*sin(theta)*sin(phi)
        z = uniform(-Z_LIM, Z_LIM)*cos(phi)
    elif (constants.START_MODE>3): # disk with/out spin
        theta = uniform(0, 2*PI)
        x = uniform(0, X_LIM)*cos(theta)#*sin(phi)  # use x_lim for disk/sphere to keep consistent
        y = uniform(0, Y_LIM)*sin(theta)#*sin(phi)
        z = uniform(-Z_LIM, Z_LIM) #  *cos(phi)
    else: # random or cube
        x = uniform(-X_LIM, X_LIM)
        y = uniform(-Y_LIM, Y_LIM)
        z = uniform(-Z_LIM, Z_LIM)

    # tangent lines
    if (constants.START_MODE==5 or constants.START_MODE==3): # disk or sphere with spin
        tz = uniform(-500, 500)
        if clockwise:
            tx = -sin(theta)*uniform(0, RAND_SPEED)
            ty = cos(theta)*uniform(0, RAND_SPEED)
        else:
            tx = sin(theta)*uniform(0, RAND_SPEED)
            ty = -cos(theta)*uniform(0, RAND_SPEED)
    elif constants.RAND_SPIN:
        tx = uniform(-RAND_SPEED, RAND_SPEED)
        ty = uniform(-RAND_SPEED, RAND_SPEED)
        tz = uniform(-RAND_SPEED, RAND_SPEED)

    return uniform(1_000_000, 9_223_372_036_854_775_807)*10_000, x, y, z, tx, ty, tz

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

cdef bool move_particle(particle_s& self, particle_s*& merged, cset[int]& ignore, vec3& mlist, unsigned int& length) noexcept:
    '''Moves a particle through space based on the positions of others particles
    Parameters
    :self: the particle being moved
    :others: An iterable of Particle objects.
    Returns void'''
    '''Dist func: |(1/sin(θ))*base|'''
    if (ignore.contains(self.hashed)):
        return False
    cdef int index = 0
    cdef double temp_force, temp, sqr_mag1, x, y, z, tx, ty, tz, mass, sqr_mag, time_d=1, tot_dist=0, tot_mass=0, 
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
        sqr_mag = sqrt(temp)  # apparently this should be fast enough
        sqr_mag1 = 1/sqr_mag
        temp_force = (GRAVITY_CONST*mass/temp)
        if temp_force > C_CONST:  # cap
            temp_force = C_CONST
        tot_mass+=mass
        tot_dist+=sqr_mag
        net_f_x = fma(temp_force, tx*sqr_mag1, net_f_x)
        net_f_y = fma(temp_force, ty*sqr_mag1, net_f_y)
        net_f_z = fma(temp_force, tz*sqr_mag1, net_f_z)
        #net_f_x += (temp_force)+(tx*sqr_mag1)
        #net_f_y += (temp_force)+(ty*sqr_mag1)
        #net_f_z += (temp_force)+(tz*sqr_mag1)


    #TODO: this code - (self.vx*self.vx)+(self.vy*self.vy)+(self.vz*self.vz)
    # it is sometimes greater than C^2, which results in a NaN value after a square root, resulting in a broken simulation, figure out a way to efficiently limit speed.

    time_d = time_dilation(tot_mass, tot_dist)
    #speed_d = speed_dilation((self.vx*self.vx)+(self.vy*self.vy)+(self.vz*self.vz))*time_d


    self.vx = fma(net_f_x,time_d, self.vx)  # increase velocity according to gravity
    self.vy = fma(net_f_y,time_d, self.vy)
    self.vz = fma(net_f_z,time_d, self.vz)




    self.x = fma(self.vx,time_d, self.x)  # move according to velocity
    self.y = fma(self.vy,time_d, self.y)
    self.z = fma(self.vz,time_d, self.z)

    mlist.push_back((self.x, self.y, self.z, self.mass))
    return True
    
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
        if unlikely(length!=self.length):
            merging = <particle_s*>realloc(merging, (sizeof(particle_s)*length))
        free(self.particles)
        self.particles = merging
        self.length = length
        merged_list.shrink_to_fit()
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
    cdef float begin, end
    cdef vector[dtuple] data
    cdef bool clockwise = uniform(0, 1) > 0.5
    data.reserve(constants.BODIES)
    for i in range(constants.BODIES):
        data.push_back(rand_point(clockwise))
    
    cdef Handler handler = Handler(data)
    data.clear()
    data.shrink_to_fit()
    cdef vector[vec3] particles
    particles.reserve(constants.N_FRAMES)
    i = 0
    begin = (time.perf_counter())
    try:
        if constants.OUTPUT:
            while 1:
                particles.push_back(handler.move_timestep())
                i += 1
                PyErr_CheckSignals()

                    
                printf("%u\r", i)
        else:
            while 1:
                # running without printing timestep is faster than doing so
                particles.push_back(handler.move_timestep())
                PyErr_CheckSignals()
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
