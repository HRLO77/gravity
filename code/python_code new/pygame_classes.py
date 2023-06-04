import math, constants, classes, pygame
import numpy as np
np.ALLOW_THREADS = True

class sprite(pygame.sprite.Sprite):
    '''A wrapper for individual particle bodies for pygame'''
    
    def __init__(self, color, x: float=0, y: float=0, mass: float=10_00, force: float=1):
        super().__init__()
        self.image = pygame.Surface([constants.SIZE, constants.SIZE])
        self.image.fill(color)  # blue
        pygame.draw.rect(self.image,
                         color,
                         pygame.Rect(0, 0, constants.SIZE, constants.SIZE))
  
        self.rect = self.image.get_rect()
        # self.image.unlock()
        self.rect.x = x+constants.X_SUB
        self.rect.y = y+constants.Y_SUB
        self.x = x+constants.X_SUB
        self.y = y+constants.Y_SUB
        self.color = color
        self.particle = classes.particle(mass, x, y, force)
    
    def update_physics(self, particles: list):
        '''Updates position, direction and forces.'''
        self.particle.move(particles, constants.FACTOR)
        self.particle.goto()
        self.rect.x, self.x = [(self.particle.x)+constants.X_SUB]*2
        self.rect.y, self.y = [(self.particle.y)+constants.Y_SUB]*2
        # print(self.x, self.y)
        # pygame.draw.rect(screen, self.color, pygame.Rect(self.x, self.y, constants.SIZE, constants.SIZE))
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
        
    
    def move_timestep(self, first: int=11, last: int=-3, take_part: int=30, direction_func=np.median, limit: float=2, skip: int=1):
        '''Moves all the particles one time step.'''
        # print('running')
        c = 0
        # print(self.particles)
        
        if not constants.DIRECT:
            for sprite in self.particles:
                angle = np.arctan2(sprite.particle.y-p.particle.y,sprite.particle.x-p.particle.x)
                p = ((p.particle, abs((1/(np.sin(angle) if angle!=1 else 1))*sprite.particle.x-p.particle.x)) for p in self.particles[:c]+self.particles[c+1:])
                p = [*sorted(p, key=lambda x: x[-1])]
                asp = tuple()
                if any(part[1] < limit for part in p):
                    index = 0
                    ignore_p = {(p.pop(index), part[0],index:= index+1)[0] for part in p if part[1] < limit}
                    mass, x, y, force = zip(*((part[0].mass, part[0].x, part[0].y, part[0].force) for part in ignore_p))
                    mass, x, y, force = np.sum(mass), direction_func(x), direction_func(y), np.sum(force)
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
                    mass, x, y, force = np.sum(mass), direction_func(x), direction_func(y), np.sum(force)
                    asp = (*asp, classes.particle(mass, x, y, force))
                    cp+=1
                # ind = [1, 0]
                # cur = 0
                # a = []
                # while True:
                #     spr = p[cur:cur+ind[0]]
                #     if spr==[]:
                #         break
                #     dat = [*zip(*[(part.particle.mass, part.particle.x, part.particle.y, part.particle.force) for part in spr])]
                    
                #     mass, x, y, force = np.sum(dat[0]), np.mean(dat[1]), np.mean(dat[2]), np.sum(dat[3])
                #     a += [classes.particle(mass, x, y, force)]
                #     cur += ind[0]
                #     ind[-1] += 1
                #     if ind[-1] >= 15:
                #         ind[0] += 1
                #         ind[-1] = 0
                # print(fp + asp) 
                sprite.update_physics((*fp, *asp))
                c+=1
        else:
            c=0
            for sprite in self.particles:
                sprite.update_physics(self.particles[:c]+self.particles[c+1:])
                c+=1
        # exit()
        return self.particles
    
    
    def __eq__(self, __value: object) -> bool:
        return __value.particles == self.particles
    
    
    def __hash__(self) -> int:
        return hash(self.particles)