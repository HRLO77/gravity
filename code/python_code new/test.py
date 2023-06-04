# from math import atan2
# print(atan2(4.5, 4.5)) # note to self: 
import constants, pygame_classes, pygame
import numpy as np
print(pygame.init())
pygame.event.set_allowed([pygame.QUIT])
screen = pygame.display.set_mode((constants.X, constants.Y), pygame.DOUBLEBUF | pygame.GL_DOUBLEBUFFER | pygame.HWACCEL | pygame.HWSURFACE | pygame.HWPALETTE, 1)
pygame.display.set_caption("Gravity simulation")

all_sprites_list = pygame.sprite.Group()
handler = pygame_classes.handler([(10e200, 900, 900, 0), *[[np.random.randint(100_000, 10_000_000), np.random.randint(-500, 500), np.random.randint(-500, 500), 1] for p in range(constants.BODIES)]])
clock = pygame.time.Clock()

np.ALLOW_THREADS = True
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
    handler.move_timestep(first=10, last=-3, take_part=10, limit=13, skip=2, direction_func=np.median)
    screen.fill((0, 0, 0))
    all_sprites_list.draw(screen)
    pygame.display.update()
    clock.tick(1000)
# else:
    
#     handler.move_timestep()
    