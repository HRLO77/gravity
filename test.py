import pickle
import numpy as np
import time
with open('data.pickle', 'rb') as f:
    data = np.array(pickle.load(f)[0])
    
for i in data:
    print(i[0], end='\r')
    time.sleep(0.1)