if bool(int(input('Execute in cython: '))):
    import animate
else:

    import matplotlib.pyplot as plt
    import matplotlib.animation as animation
    from matplotlib.animation import PillowWriter
    import numpy as np
    fig = plt.figure()

    #creating a subplot 
    ax1 = fig.add_subplot(1,1,1)

    import pickle
    save = bool(int(input('Save animation as video or render realtime? [1/0]: ')))
    with open('data.pickle', 'rb') as f:
        data = np.array(pickle.load(f)[0], dtype=np.float16)

    con = np.array([2 for i in range(data.shape[1])], dtype=np.ubyte)
    c = 0
    def animate(i):
        
        global c, con
    
        
        ax1.clear()
        ax1.scatter(*zip(*data[i]), con)
        plt.xlabel('X')
        plt.ylabel('Y')
        plt.title('Gravitational simulation')
        c += 1

    plt.ioff()
    ani = animation.FuncAnimation(fig, animate, interval=1 if save else 1000/30, cache_frame_data=data.shape[1] < 5_000, frames=data.shape[0])

    if save:
        ani.save(f'./{np.random.randint(0, 2_000_000)}.gif', writer=PillowWriter(fps=30))
    else:
        plt.show()
