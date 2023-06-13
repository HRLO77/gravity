
import math
import numpy as np

np.ALLOW_THREADS = True
# shape of grid is 3 dimension, 2 spatial dimensions 3rd is temporal for gravity
# (10 (gravity), 10 (x), 10 (y), 2 (num_particles, weight))
[
    [[3, 0.1],[5, 0.7],[8, 0.3]],
    [[0, 0],[6, 0.2],[8, 1]],
    [[7, 0.7],[15, 0.15],[0, 0]],
]  # for example
# TODO: please figure out how will particles move in between.
X = 1920  # x size
Y = 1080  # y size
X_SUB = np.ceil(X/2)
Y_SUB = np.ceil(Y/2)
ORIGIN = (X-X_SUB, Y-Y_SUB)
# K = 50  # n particles
# grid: list[list[list]] = [[[] for y in '~'*Y] for x in '~'*X]  # grid
G = 6.67430*10e-11 # gravitational constant
SOFTEN = 1  # the softening factor
# with open('pi.txt') as f:
RADIAN_DIV = np.pi/180
SIZE = 5
TIMESTEP = 0.001
MOVESTEP = 1
NEWT_MAX = (30570322.995110463)/SIZE**2
BODIES = int(input("Enter bodies: "))
# DISSIPATE = bool(int(input('Enter dissipation: ')))
DIRECT = bool(int(input("Direct-sum?: ")))