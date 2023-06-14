import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

plt.autoscale(False)
plt.xlim(2000)
plt.ylim(1200)
fig = plt.figure()

#creating a subplot 
ax1 = fig.add_subplot(1,1,1)
ax1.autoscale(False)
ax1.autoscale_view(False)
ax1.set_ylim(1200)
ax1.set_xlim(2000)

import pickle
with open('data.pickle', 'rb') as f:
    data = pickle.load(f)[0]
c = 00
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
    ax1.scatter(xs, ys, [2 for i in range(len(xs))])

    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('Gravitational simulation')
    c += 1
	
    
ani = animation.FuncAnimation(fig, animate, interval=1000/30, save_count=30)
plt.show()