import math, constants
import numpy as np

np.ALLOW_THREADS = True
class unit:
    '''Represents a single unit in spatial co-ordinate plane, cannot be moved through higher dimensions.'''

    def __init__(self, mass: float, x: int, y: int) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        self.velocity_x = np.random.randint(-500, 500)
        self.velocity_y = np.random.randint(-500, 500)
        

    def calculate_force(self, other=None, weight: float | None=None, position=None):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        if isinstance(other, self.__class__):
            f = (math.dist((other.x, self.y), (other.x, self.y)))
            if f > 0:
                return (constants.G*self.mass*other.mass)/f**2+(f*constants.SOFTEN)
            return (constants.G*self.mass*other.mass)/1+(1*constants.SOFTEN)
        else:
            f = (math.dist((self.x, self.y), ((position[0]), (position[1]))))
            if f > 0:
                return (constants.G*self.mass*weight)/f**2+(f*constants.SOFTEN)
            return (constants.G*self.mass*weight)/1+(1*constants.SOFTEN)
    

    def calculate_direction(self, other=None, position=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        assert isinstance(position, tuple) or position==None
        if isinstance(other, self.__class__):
            t = np.arctan2(self.y-other.y, self.x-other.x)
            # slope = math.tan(t)
            return t*constants.RADIAN_DIV
        else:
            t = np.arctan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
            return t*constants.RADIAN_DIV
    
class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    
    def __init__(self, mass: float, x: float | int, y: float | int) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        self.velocity_x = np.random.randint(-1, 1)
        self.velocity_y = np.random.randint(-1, 1)
        
      
    def calculate_force(self, other=None, weight: float | None=None, position=None, dist=None):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        f = (position[0]-self.x)**2+(position[1]-self.y)**2
        # f = f**np.log2(f)
        # if f < constants.SIZE:
        #     f = constants.SIZE**2
        return ((constants.G*self.mass*weight)/(f if f > 0 else constants.SIZE))  # if (self.f) > 0 else (constants.G*self.mass*weight)/1+(constants.SOFTEN)
        # assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        # if isinstance(other, self.__class__):
        #     f = (math.dist((other.x, self.y), (other.x, self.y)))
        #     if f > 0:
        #         return (constants.G*self.mass*other.mass)/f**3+(f*constants.SOFTEN)
        #     return (constants.G*self.mass*other.mass)/1+(1*constants.SOFTEN)
        # else:
        #     f = dist
        #     if f > 0:
        #         return (constants.G*self.mass*weight)/f**2
        #     return (constants.G*self.mass*weight)/1
        
      
    def calculate_direction(self, position=None, angle=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        t = np.arctan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
        return t*constants.RADIAN_DIV
        
      
    def move(self, others:  list | tuple):
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        net_f_x, net_f_y = (0, 0)
       
        top = type(others[0]) == self.__class__
        if top:
            for index in range(len(others)):
                temp_dir = self.calculate_direction(position=(others[index].x, others[index].y))
                temp_force = self.calculate_force(position=(others[index].x, others[index].y), weight=others[index].mass)
                if temp_force > constants.NEWT_MAX:
                    temp_force = constants.NEWT_MAX
                net_f_x += np.cos(temp_dir)*temp_force
                net_f_y += np.sin(temp_dir)*temp_force
                mass, x, y, = others[index].mass, others[index].x, others[index].y
                s = np.sin(temp_dir)
                f += mass*abs((x-y)*temp_force) / abs(self.mass*((1/(1 if s==0 else s))*x-self.x)**2)
        else:
            for index in range(len(others)):
                mass, x, y = others[index].particle.mass, others[index].particle.x, others[index].particle.y

                temp_dir = self.calculate_direction(position=(x, y))

                s = np.sin(temp_dir)
                dist = abs((1/s if s !=0 else 1)*x-self.x)
                temp_force = self.calculate_force(position=(x, y), weight=mass, dist=dist)
                # print(temp_force)
                # if temp_force > constants.NEWT_MAX:
                #     temp_force = constants.NEWT_MAX

                net_f_x += ((x-self.x)*temp_force)
                net_f_y += ((y-self.y)*temp_force)

                


        #Fx, Fy = zip(*((f*np.cos(p),f*np.sin(p)) for p, f in calculations))
        #net_f_x = ((np.sum(Fx)))
        #net_f_y = ((np.sum(Fy,)))
        #net_force += (((net_f_x**2) + (net_f_y**2)))

        
        #l = mass*np.cross((self.x, self.y), [net_mom, net_mom]) / self.mass*1 if k==0 else k
        #net_force += l
        # print(net_force, 'net')
        #vx_current = self.force * np.cos(self.direction,)
        #vy_current = self.force * np.sin(self.direction,)
        #vx_net = -vx_current + (net_f_x / self.mass)
        #vy_net = -vy_current + (net_f_y / self.mass)
        # vx_required = ((vx_current**2)+(vy_current**2))**0.5
        #f_required_x = self.mass*vx_net
        #f_required_y = self.mass*vy_net
        #force_required = ((f_required_x**2)+(f_required_y**2))**0.5
        self.velocity_x += net_f_x*constants.TIMESTEP
        self.velocity_y += net_f_y*constants.TIMESTEP
        
        # if abs(self.velocity_x) > constants.SIZE**2:
        #     self.velocity_x /= constants.SIZE*2
        # if abs(self.velocity_y) > constants.SIZE**2:
        #     self.velocity_y /= constants.SIZE*2
        # print(net_force)
        # if fk:
        #     if direction < (3*np.pi)/2 and direction > np.pi/2:
        #         direction += 1.178097
        #     else:
        #         direction -= 1.178097
        #     self.mov_angle = True
        #     self.direction = direction
        #     self.force = net_force
            # return
        # print(f ** 2, net_force, force_required)

            # p = f*f
        # p = float(f'{f}'.split('e')[0][:10])
        
        # exit()
        # print(p)
        #force_angular = np.cross((self.x, self.y), (np.cos(direction*f), np.cos(direction*f))) * self.mass
        # print(f, force_required, direction)
        # exit()
        # print(f, direction)

    
    def goto(self):
        '''Moves X and Y position based on a timestep, current direction and force.'''
        self.x += self.velocity_x
        self.y += self.velocity_y
        if self.x >= constants.X_SUB:
            self.x = -constants.X_SUB
        elif self.x <= -constants.X_SUB:
            self.x = constants.X_SUB
        if self.y >= constants.Y_SUB:
            self.y = -constants.Y_SUB
        elif self.y <= -constants.Y_SUB:
            self.y = constants.Y_SUB

    
    
    def __eq__(self, __value: object) -> bool:
        return (self.x, self.y, self.mass, self, self.velocity_x, self.velocity_y) == (__value.x, __value.y, __value.mass, __value.velocity_x, __value.velocity_y)
    
    
    def __hash__(self) -> int:
        return hash((self.x, self.y, self.mass, self.velocity_x, self.velocity_y))