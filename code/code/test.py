# from math import atan2
# print(atan2(4.5, 4.5)) # note to self: 
import constant, pygame_classes, pickle, queue, threading, time, random
handler = pygame_classes.handler([*[[random.randint(100, 10_000), random.randint(-500, 500), random.randint(-500, 500), random.randint(1000, 100_000)] for p in range(constant.BODIES)]])

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
with open('data.pickle', 'wb') as f:
    pickle.dump([], f)
qu = queue.Queue()
def forever():
    data = []
    while True:
        while qu.qsize() == 0:
            time.sleep(0.1)
        data += [qu.get_nowait() for i in range(qu.qsize())]
        if [-0] in data:
            break
    print('Loading data...')
    with open('data.pickle', 'wb') as f:
        pickle.dump([*sorted(data, key=lambda x:x[0])], f)
    print('Dumping handler...')
# if ('y' in input("Render realtime [Y] or fast? [N]: ").lower()):
    # print('Going')
thread = threading.Thread(target=forever)
thread.start()
running  = True
t = time.perf_counter()
try:
    while True:# all_sprites_list.update()
    # while Q.qsize() < 1:
    #     pass
        qu.put_nowait((qu.qsize(), handler.move_timestep(first=2, last=-1, take_part=9998, limit=7, skip=1)))
except BaseException as e:
    print(str(e))
print(time.perf_counter()-t)
qu.put_nowait([-0])
time.sleep(1)
# else:
    
#     handler.move_timestep()
    