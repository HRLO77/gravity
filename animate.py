import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

fig = plt.figure()
#creating a subplot 
ax1 = fig.add_subplot(1,1,1)
import pickle
with open('data.pickle', 'rb') as f:
    data = pickle.load(f)
c = 0
prev = 0
def animate(i):
    
    global c
    global prev
    xs = []
    ys = []
    # print(prev==data[c])
    for x, y in data[c]:
        xs.append(x)
        ys.append(y)
   
    
    ax1.clear()
    ax1.scatter(xs, ys)

    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('Gravitational simulation')
    c += 1
	
    
ani = animation.FuncAnimation(fig, animate, interval=1000/30, save_count=30)
plt.show()