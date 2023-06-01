import math, constant, classes, statistics

class sprite:
    '''A wrapper for individual particle bodies'''
    
    def __init__(self, color, x: float=0, y: float=0, mass: float=1000, force: float=1):
        self.particle = classes.particle(mass, x, y, force)
        
    
    def update_physics(self, particles: list):
        '''Updates position, direction and forces.'''
        self.particle.move(particles, constant.FACTOR)
        self.particle.goto()
        # self.rect.x, self.x = [(self.particle.x)+constant.X_SUB]*2
        # self.rect.y, self.y = [(self.particle.y)+constant.Y_SUB]*2
        return self.particle.direction, self.particle.force
    
    
    def __eq__(self, __value: object) -> bool:
        return self.particle == __value.particle
    
    
    def __hash__(self) -> int:
        return hash(self.particle)

class handler:
    '''A class wrapper to handle multiple pygame sprites, wrapping particles.'''
    
    def __init__(self, weights) -> None:
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = tuple(sprite((255, 255, 255), x, y, mass, force) for mass, x, y, force in weights)
        
    
    def move_timestep(self, first: int=11, last: int=-3, take_part: int=30, direction_func=statistics.median_grouped, limit: float=2, skip: int=1):
        '''Moves all the particles one time step.'''
        # print('running')
        c = 0
        # print(self.particles)
        for sprite in self.particles:
            if constant.DIRECT:
                p = [*self.particles]
                p.pop(c)
                sprite.update_physics([i.particle for i in p])
            else:
                p = ((p.particle, math.dist((sprite.particle.x, sprite.particle.y), (p.particle.x, p.particle.y))) for p in self.particles[:c]+self.particles[c+1:])
                p = [*sorted(p, key=lambda x: x[-1])]
                asp = tuple()
                if any(part[1] < limit for part in p):
                    index = 0
                    ignore_p = {(p.pop(index), part[0],index:= index+1)[0] for part in p if part[1] < limit}
                    mass, x, y, force = zip(*((part[0].mass, part[0].x, part[0].y, part[0].force) for part in ignore_p))
                    mass, x, y, force = sum(mass), direction_func(x), direction_func(y), sum(force)
                    asp = (*asp, classes.particle(mass, x, y, force))
                p = tuple(part[0] for part in p)
                fp = p[:first]
                p = p[first:]
                associate = tuple()
                ask = set()
                for part in p[last::skip]:
                    closest = sorted(p, key=lambda x: math.dist((part.x, part.y), (x.x, x.y)))
                    kp = [i for i in closest[:take_part] if not i in ask]
                    associate, ask = (*associate, part, *kp), {*ask, part, *kp}
                cp = 0
                for n in associate[::take_part]:
                    mass, x, y, force = zip(*((p.mass, p.x, p.y, p.force) for p in associate[cp*take_part:(cp+1)*take_part]))
                    mass, x, y, force = sum(mass), direction_func(x), direction_func(y), sum(force)
                    asp = (*asp, classes.particle(mass, x, y, force))
                    cp+=1
                    c+=1
        # exit()
        return self.particles
    
    
    def __eq__(self, __value: object) -> bool:
        return __value.particles == self.particles
    
    
    def __hash__(self) -> int:
        return hash(self.particles)