import math, constants
import numpy as np

np.ALLOW_THREADS = True
class unit:
    '''Represents a single unit in spatial co-ordinate plane, cannot be moved through higher dimensions.'''

    def __init__(self, mass: float, x: int, y: int) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        

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
            return t/constants.RADIAN_DIV
        else:
            t = np.arctan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
            return t/constants.RADIAN_DIV
    
class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    
    def __init__(self, mass: float, x: float | int, y: float | int, force: float | int = 0) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        self.direction = 1
        self.force = force
        
      
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
        
      
    def calculate_direction(self, other=None, position=None, angle=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        return (1/)
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        assert isinstance(position, tuple) or position==None
        if isinstance(other, self.__class__):
            t = np.arctan2(self.y-other.y, self.x-other.x)
            # slope = math.tan(t)
            return t/constants.RADIAN_DIV
        else:
            t = np.arctan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
            return t/constants.RADIAN_DIV
        
      
    def move(self, others:  list | tuple, factor_to_move: float | int | np.dtype=1):
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        if type(others)==dict:
            calculations = sorted(((self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))) for p, w in others.items())  # calculate directions to face to, and the force of attraction
        else:
            calculations = sorted(((self.calculate_direction(position=(p.x, p.y))), self.calculate_force(position=(p.x, p.y), weight=p.mass)) for p in others)
        # if type(others)==dict:
        #     calculations = sorted([(self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))] for p, w in others.items())  # calculate directions to face to, and the force of attraction
        # else:

        #     Fx, Fy = zip(*[(part.force*np.cos(part.direction, dtype=float), part.force*np.sin(part.direction, dtype=float)) for part in others])
        # print(Fx, Fy, [(part.force*np.cos(part.direction), part.force*np.sin(part.direction)) for part in others])
        # exit()
        a = []
        # max_d, max_f = calculations[0]
        
        f = self.force
        for index in range(len(others)):
            to_atan = np.arctan2(others[index].y-self.y, others[index].x-self.x)
            temp_dir = self.calculate_direction((others[index].x, others[index].y), to_atan)
            temp_force = self.calculate_force((others[index].x, others[index].y), others[index].mass, to_atan)
            net_f_x += np.cos(temp_dir)*temp_force
            net_f_x += np.sin(temp_dir)*temp_force
        Fx, Fy = zip(*((f*np.cos(p),f*np.sin(p)) for p, f in calculations))
        net_f_x = ((np.sum(Fx)))
        net_f_y = ((np.sum(Fy,)))
        net_force = (((net_f_x**2) + (net_f_y**2))**0.5)
        # print(net_force, 'net')
        vx_current = self.force * np.cos(self.direction,)
        vy_current = self.force * np.sin(self.direction,)
        vx_net = -vx_current + (net_f_x / self.mass)
        vy_net = -vy_current + (net_f_y / self.mass)
        # vx_required = ((vx_current**2)+(vy_current**2))**0.5
        f_required_x = self.mass*vx_net
        f_required_y = self.mass*vy_net
        force_required = ((f_required_x**2)+(f_required_y**2))**0.5
        direction = np.arctan2(net_f_y, net_f_x)
        
        # print(f ** 2, net_force, force_required)

            # p = f*f
        # p = float(f'{f}'.split('e')[0][:10])
        
        # exit()
        p = f
        # print(p)
        if f>0:f = (((net_force / (p)))-force_required)*factor_to_move
        else:f = (net_force-force_required)*factor_to_move

        # print(f, force_required, direction)
        # exit()
        # print(f, direction)
        self.direction = direction
        # try:
        self.force = f
        # except ValueError as e:
            # print(str(e))
        # print(prev, 'test', f, net_force, factor_to_move, 'test', (net_f_x*net_f_x) + (net_f_y*net_f_y), net_f_x, net_f_y)
            # exit()
        return self.direction, self.force

    
    def goto(self):
        '''Moves X and Y position based on a timestep, current direction and force.'''
        far = self.direction*constants.RADIAN_DIV
        if constants.DISSIPATE:self.force = self.force-((self.force*0.001 if not(self.force==np.nan or self.force==0) else 0))  # attempted reality :(
        move_x = (np.cos(far,))
        move_y = (np.sin(far,))
        self.x += move_x
        self.y += move_y
        if self.x >= constants.X_SUB:
            self.x = -constants.X_SUB
        elif self.x <= -constants.X_SUB:
            self.x = constants.X_SUB
        if self.y >= constants.Y_SUB:
            self.y = -constants.Y_SUB
        elif self.y <= -constants.Y_SUB:
            self.y = constants.Y_SUB
        return move_x, move_y
    
    
    def __eq__(self, __value: object) -> bool:
        return (self.force, self.x, self.y, self.mass, self.direction) == (__value.force, __value.x, __value.y, __value.mass, __value.direction)
    
    
    def __hash__(self) -> int:
        return hash((self.force, self.x, self.y, self.mass, self.direction))