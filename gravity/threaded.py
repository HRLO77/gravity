import pygame, os, math, cmath, threading, queue, constants, functools, classes_code
import numpy as np

class sprite(pygame.sprite.Sprite):
    '''A wrapper for individual particle bodies for pygame'''
    
    def __init__(self, color: tuple[int, int, int], x: float, y: float, mass: float=100):
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
        self.particle = classes_code.particle(mass, x, y)
        
    def update_physics(self, particles: list, index):
        '''Updates position, direction and forces.'''
        self.particle.move([i.particle for i in particles], constants.FACTOR)
        self.particle.goto()
        self.rect.x, self.x = [(self.particle.x)+constants.X_SUB]*2
        self.rect.y, self.y = [(self.particle.y)+constants.Y_SUB]*2
        # print(self.x, self.y)
        # pygame.draw.rect(screen, self.color, pygame.Rect(self.x, self.y, constants.SIZE, constants.SIZE))
        return self, index
    

class handler:
    '''A class wrapper to handle multiple pygame sprites, wrapping particles.'''
    
    def __init__(self, weights: tuple[tuple[float, float, float]]) -> None:
        '''Accepts a tuple of tuples, each tuple having the mass, starting x, and starting y positions for each particle.'''
        self.particles = [sprite((255, 255, 255), x, y, mass) for mass, x, y in weights]
        
    def move_timestep(self, screen):
        '''Moves all the particles one time step.'''
        q = queue.Queue()
        c = 0
        k = []
        for sprite in self.particles:
            p = [*self.particles].copy()
            p.pop(c)
            k += [threading.Thread(target=(lambda f, *a: q.put_nowait(f(*a))), args=[sprite.update_physics, p, c])]
            c+=1
        for p in k:
            p.start()
        while q.qsize() != len(self.particles):
            pass
        ls = [q.get_nowait() for j in range(q.qsize())]
        self.particles = [*zip(*ls)][0]
        return [*self.particles]