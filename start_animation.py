
if bool(int(input('Execute in cython: '))):
    import animate
else:

    import matplotlib.pyplot as plt
    import matplotlib.animation as animation
    from matplotlib.animation import FFMpegWriter
    import matplotlib.style as mplstyle
    mplstyle.use('fast')
    mplstyle.use(['dark_background', 'ggplot', 'fast'])

    import numpy as np
    bounds = not bool(int(input('Dynamic bounds [1] or static bounds [0]?: ')))
    padding = False
    if bounds:
        
        xlim = [int(input('X bounds (integer)?: '))]*2
        xlim[0] = xlim[0]*-1
        ylim = [int(input('Y bounds (integer)?: '))]*2
        ylim[0] = ylim[0]*-1
    if not bounds:
        if bool(int(input('Extra padding on dynamic bounds [1/0]?: '))):
            padding = True
            pad_x = float(input('X padding (float 0-1)?: '))
            pad_y = float(input('Y padding (float 0-1)?: '))

    fig = plt.figure()

    #creating a subplot
    if bounds:
        plt.autoscale(False)
        plt.xlim(xlim)
        plt.ylim(ylim)
    ax1 = fig.add_subplot(1,1,1)
    ax1.set_rasterized(True)
    import pickle
    save = bool(int(input('Save animation as video or render realtime? [1/0]: ')))
    with open('data.pickle', 'rb') as f:
        data = np.array(pickle.load(f)[0], dtype=np.float32)

    con = np.array([1 for i in range(data.shape[1])], dtype=np.ubyte)
    def animate(i):
        
        global c, con
        try:
            ax1.clear()
            if bounds:
                ax1.set_xlim(xlim)
                ax1.set_ylim(*ylim)
            elif padding:
                ax1.set_xmargin(pad_x)
                ax1.set_ymargin(pad_y)
            ax1.scatter(*zip(*data[i]), con)

            plt.xlabel('X')
            plt.ylabel('Y')
            plt.title('Gravitational simulation')
        except BaseException:
            if save:
                ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=25))
            else:
                plt.show()
    plt.ioff()
    ani = animation.FuncAnimation(fig, animate, interval=1 if save else 1000/25, cache_frame_data=data.shape[1] < 5_000, frames=data.shape[0])

    if save:
        ani.save(f'./{np.random.randint(0, 2147483647)}.mp4', writer=FFMpegWriter(fps=25))
    else:
        plt.show()
