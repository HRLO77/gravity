# from math import atan2
# print(atan2(4.5, 4.5)) # note to self: 
import classes, math, constants, asyncio, pygame, threading, queue, pygame_classes, pickle, statistics, cmath
import numpy as np
print(pygame.init())
screen = pygame.display.set_mode((constants.X, constants.Y))
pygame.display.set_caption("Gravity simulation")

all_sprites_list = pygame.sprite.Group()
handler = pygame_classes.handler([*[[np.random.randint(100_000, 10_000_000), np.random.randint(-500, 500), np.random.randint(-500, 500), np.random.randint(1000, 100_000)] for p in range(constants.BODIES)]])
clock = pygame.time.Clock()


# p1 = classes.particle(50, 0, 0)

# p2 = classes.particle(50, -1, -1)

# p3 = classes.particle(75, 3, 1)

# p4 = classes.particle(75, 3, 1)

# particles = [p1, p2, p3, p4]
# Q = queue.Queue()

# def cont(handle: pygame_classes.handler):
#     s = pygame.sprite.Group()
#     s.add(handle.move_timestep())
#     Q.put_nowait(s)
#     threading.Thread(target=cont, args=[handle]).start()
#     return

# sprite1 = pygame_classes.sprite((255, 255, 255), 0, -50, 150)
# for i in range(100):
#     s = pygame.sprite.Group()
#     s.add(handler.move_timestep())
#     Q.put_nowait(s)
# threading.Thread(target=cont, args=[handler]).start()


def get_iterables(iterables: list | tuple | set, obj_ignore):
    '''Iterates through the iterables given, and returns it without the obj_ignore.'''
    y = [*iterables]
    y.remove(obj_ignore)
    return y


all_sprites_list.add(handler.particles)
# if ('y' in input("Render realtime [Y] or fast? [N]: ").lower()):
    # print('Going')
running  = True
while running:  
    for event in pygame.event.get():
        if event.type == pygame.QUIT:  
            exit()
        # all_sprites_list.update()
        # while Q.qsize() < 1:
        #     pass
    all_sprites_list.update()
    handler.move_timestep(first=7, last=-3, take_part=20, direction_func=statistics.median_grouped, limit=5)
    screen.fill((0, 0, 0))
    all_sprites_list.draw(screen)
    pygame.display.flip()
    clock.tick(360)
# else:
    
#     handler.move_timestep()
    