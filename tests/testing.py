# # # import pyximport; pyximport.install(pyimport=True, inplace=True)
# # # import pickle
# # from matplotlib import pyplot as plt
# # import numpy as np
# # # data = pickle.load(open('test.pickle', 'rb'))
# # # print(data[9000])
# # data = np.array([np.random.randint(1_000_000, 2_147_483_647)*150 for i in range(10000)], np.float32)
# # print(np.mean(data), np.median(data))
# # plt.plot(data)
# # plt.show()


# import matplotlib.pyplot as plt

# from mpl_toolkits.mplot3d import axes3d

# fig = plt.figure()
# ax = fig.add_subplot(projection='3d')

# # Grab some example data and plot a basic wireframe.
# X, Y, Z = axes3d.get_test_data(0.03)
# ax.plot_wireframe(X, Y, Z, rstride=25, cstride=25)

# # Set the axis labels
# ax.set_xlabel('x')
# ax.set_ylabel('y')
# ax.set_zlabel('z')

# # Rotate the axes and update
# roll=0
# azim=0
# elev=0
# while True:

#     # roll -= 10
#     azim += 1
#     # elev += 1 
#     # Update the axis view and title
#     ax.view_init(elev, azim, roll)
#     plt.title('Elevation: %d°, Azimuth: %d°, Roll: %d°' % (elev, azim, roll))

#     plt.draw()
#     plt.pause(.001)
from numpy import sqrt

f = 5.97219*10e24
r = float((input("Enter dist: ")))
G2 = (6.6743 * 10e-11)*2
CS = 299792458.0*299792458.0
print(sqrt(1-((G2*f)/(CS*r))))