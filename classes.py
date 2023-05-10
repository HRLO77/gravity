import math, threading, queue, constants, numba
import numpy as np


# def is_positive(num: int | float) -> bool:
#     '''Returns whether or not a number is positive'''
#     return f'{num}'[0] == '-'  # lmfao

# def run(function, *args, **kwargs):
#     '''Éxecutes multiple functions on a seperate thread and returns the result.'''
#     q = queue.Queue()
#     lmb = lambda a, k, f: q.put_nowait(f(*a, **k))  # wrap it
#     t = threading.Thread(target=lmb, args=[args, kwargs, function])
#     t.run()
#     t.join()  # im stupid lmfao
#     return q.get_nowait()

# class unit:
#     '''Represents a single unit in spatial co-ordinate plane, cannot be moved through higher dimensions.'''

#     def __init__(self, mass: float, x: int, y: int) -> None:
#         self.mass = mass
#         self.x = x
#         self.y = y
        

#     def calculate_force(self, other):
#         '''Calculates the force of attraction (in newtons) between this unit of space and another body (particle or unit of space) in a higher dimension.'''
#         assert isinstance(other, self.__class__) or isinstance(other, unit), "Must be comparing to another unit in space or particle."
#         return (constants.G*self.mass*other.mass)/(math.dist((self.x, self.y), (other.x, other.y))**2)
    

#     def calculate_direction(self, other):
#         '''Calculates the direction (slope and radians) to another unit of space or particle.'''
#         assert isinstance(other, self.__class__) or isinstance(other, unit), "Must be comparing to another particle of a unit in space."
#         t = np.arctan2(other.y-self.y, other.x-self.x)
#         # slope = np.tan(t)
#         return t/constants.RADIAN_DIV
    
class particle:
    '''Represents a single particle, can be moved through higher dimensions.'''
    
    def __init__(self, mass: float, x: float | int, y: float | int, force: float | int = 1) -> None:
        self.mass = mass
        self.x = x
        self.y = y
        self.direction = 0
        self.force = force
        
    @numba.jit(cache=True)     
    def calculate_force(self, other=None, weight: float | None=None, position: tuple[int, int]=None):
        '''Calculates the force of attraction (in newtons) between this particle and another body (particle, unit of space, or position and weight) in a higher dimension.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        if isinstance(other, self.__class__):
            return (constants.G*self.mass*other.mass)/(math.dist((self.x, self.y), (other.x, other.y))**2)
        else:
            return (constants.G*self.mass*weight)/(math.dist((self.x, self.y), (round(position[0]), round(position[1])))**2)
        
    @numba.jit(cache=True)
    def calculate_direction(self, other=None, position: tuple[int, int]=None):
        '''Calculates the direction (slope and radians) to another particle, unit of space or position in space.'''
        assert isinstance(other, self.__class__) or isinstance(other, unit) or other==None, "Must be comparing to another particle of a unit in space."
        assert isinstance(position, tuple) or position==None
        if isinstance(other, self.__class__):
            t = np.arctan2(other.y-self.y, other.x-self.x)
            # slope = np.tan(t)
            return t/constants.RADIAN_DIV
        else:
            t = np.arctan2(round(position[1])-self.y, round(position[0])-self.x)
            # slope = np.tan(t)
            return t/constants.RADIAN_DIV
        
    @numba.jit(cache=True)
    def move(self, others: dict[tuple[int, int], float] | list | tuple, factor_to_move: float | int | np.dtype=1) -> tuple[float, float, float]:
        '''Based on a dict (key is x and y, value is rate of bending in 3d dimension.), calculate direction to move to and speed at which to move. Returns direction (radians), force (newtons) and slope (gradient.)'''
        if type(others)==dict:
            calculations = sorted([(self.calculate_direction(position=p), self.calculate_force(position=p, weight=w))] for p, w in others.items())  # calculate directions to face to, and the force of attraction
        else:
            calculations = sorted([(self.calculate_direction(position=(p.x, p.y))), self.calculate_force(position=(p.x, p.y), weight=p.mass)] for p in others)
        a = []
        # max_d, max_f = calculations[0]
        d, f = self.direction, self.force
        print(calculations)
        Fx, Fy = zip(*((f*np.cos(p), f*np.sin(p)) for (p, f) in calculations))
        net_f_x = sum(Fx)
        net_f_y = sum(Fy)
        net_force = (net_f_x**2 + net_f_y**2)**0.5
        theta = np.arctan2(net_f_x, net_f_y)
        vx_current = self.force * np.cos(self.direction)
        vy_current = self.force * np.sin(self.direction)
        vx_net = -vx_current + (net_f_x / self.mass)
        vy_net = -vy_current + (net_f_y / self.mass)
        f_required_x = self.mass*vx_net
        f_required_y = self.mass*vy_net
        force_required = (f_required_x**2+f_required_y**2)**0.5
        direction = np.arctan2(-net_f_y, -net_f_x)
        # print(f ** 2, net_force, force_required)
        f = (net_force / f ** 2)*factor_to_move
        gradient = np.tan(direction)
        self.direction = direction
        self.f = f
        return direction, f, gradient
    
    
    def goto(self):
        '''Moves X and Y position based on a timestep, current direction, gradient and force.'''
        gradient = np.tan(self.direction)
        force = self.force
        gradient