import math, constant


class unit:
    '''Represents a single unit in spatial co-ordinate plane, cannot be moved through higher dimensions.'''

    def __init__(self, mass: float, x: int, y: int) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        

    def calculate_force(self, other=None, weight: float or None=None, position=None):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        if isinstance(other, self.__class__):
            f = (math.dist((other.x, self.y), (other.x, self.y)))
            if f > 0:
                return (constant.G*self.mass*other.mass)/f**2+(f*constant.SOFTEN)
            return (constant.G*self.mass*other.mass)/1+(1*constant.SOFTEN)
        else:
            f = (math.dist((self.x, self.y), ((position[0]), (position[1]))))
            if f > 0:
                return (constant.G*self.mass*weight)/f**2+(f*constant.SOFTEN)
            return (constant.G*self.mass*weight)/1+(1*constant.SOFTEN)
    

    def calculate_direction(self, other=None, position=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        assert isinstance(position, tuple) or position==None
        if isinstance(other, self.__class__):
            t = math.atan2(self.y-other.y, self.x-other.x)
            # slope = math.tan(t)
            return t/constant.RADIAN_DIV
        else:
            t = math.atan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
            return t/constant.RADIAN_DIV
    
class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    
    def __init__(self, mass: float, x: float or int, y: float or int, force: float or int = 0) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        self.direction = 1
        self.force = force
        
      
    def calculate_force(self, other=None, weight: float or None=None, position=None):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        if isinstance(other, self.__class__):
            f = (math.dist((other.x, self.y), (other.x, self.y)))
            if f > 0:
                return (constant.G*self.mass*other.mass)/f**2+(f*constant.SOFTEN)
            return (constant.G*self.mass*other.mass)/1+(1*constant.SOFTEN)
        else:
            f = (math.dist((self.x, self.y), ((position[0]), (position[1]))))
            if f > 0:
                return (constant.G*self.mass*weight)/f**2+(f*constant.SOFTEN)
            return (constant.G*self.mass*weight)/1+(1*constant.SOFTEN)
        
      
    def calculate_direction(self, other=None, position=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        assert isinstance(position, tuple) or position==None
        if isinstance(other, self.__class__):
            t = math.atan2(self.y-other.y, self.x-other.x)
            # slope = math.tan(t)
            return t/constant.RADIAN_DIV
        else:
            t = math.atan2((position[1])-self.y, (position[0])-self.x)
            # slope = math.tan(t)
            return t/constant.RADIAN_DIV
        
      
    def move(self, others:  list or tuple, factor_to_move: float or int =1):
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons)'''
        if type(others)==dict:
            calculations = sorted(((self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))) for p, w in others.items())  # calculate directions to face to, and the force of attraction
        else:
            calculations = sorted(((self.calculate_direction(position=(p.x, p.y))), self.calculate_force(position=(p.x, p.y), weight=p.mass)) for p in others)
        # if type(others)==dict:
        #     calculations = sorted([(self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))] for p, w in others.items())  # calculate directions to face to, and the force of attraction
        # else:

        #     Fx, Fy = zip(*[(part.force*math.cos(part.direction, dtype=float), part.force*math.sin(part.direction, dtype=float)) for part in others])
        # print(Fx, Fy, [(part.force*math.cos(part.direction), part.force*math.sin(part.direction)) for part in others])
        # exit()
        a = []
        # max_d, max_f = calculations[0]
        
        f = self.force

        Fx, Fy = zip(*((f*math.cos(p),f*math.sin(p)) for p, f in calculations))
        net_f_x = ((sum(Fx)))
        net_f_y = ((sum(Fy,)))
        net_force = (((net_f_x**2) + (net_f_y**2))**0.5)
        # print(net_force, 'net')
        vx_current = self.force * math.cos(self.direction,)
        vy_current = self.force * math.sin(self.direction,)
        vx_net = -vx_current + (net_f_x / self.mass)
        vy_net = -vy_current + (net_f_y / self.mass)
        # vx_required = ((vx_current**2)+(vy_current**2))**0.5
        f_required_x = self.mass*vx_net
        f_required_y = self.mass*vy_net
        force_required = ((f_required_x**2)+(f_required_y**2))**0.5
        direction = math.atan2(net_f_y, net_f_x)
        
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
        far = self.direction*constant.RADIAN_DIV
        if constant.DISSIPATE:self.force = self.force-((self.force*0.001 if not(self.force==math.nan or self.force==0) else 0))  # attempted reality :(
        move_x = (math.cos(far,))
        move_y = (math.sin(far,))
        self.x += move_x
        self.y += move_y
        if self.x >= constant.X_SUB:
            self.x = -constant.X_SUB
        elif self.x <= -constant.X_SUB:
            self.x = constant.X_SUB
        if self.y >= constant.Y_SUB:
            self.y = -constant.Y_SUB
        elif self.y <= -constant.Y_SUB:
            self.y = constant.Y_SUB
        return move_x, move_y
    
    
    def __eq__(self, __value: object) -> bool:
        return (self.force, self.x, self.y, self.mass, self.direction) == (__value.force, __value.x, __value.y, __value.mass, __value.direction)
    
    
    def __hash__(self) -> int:
        return hash((self.force, self.x, self.y, self.mass, self.direction))