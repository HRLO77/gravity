import pickle
import numpy as np
import time
with open('data.pickle', 'rb') as f:
    data = np.array(pickle.load(f)[0])
    
print(data.shape)