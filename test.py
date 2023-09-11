from t import overload
from matplotlib import pyplot as plt
import numpy as np
@overload
def r(iterable: tuple[float], level: float):
    for i in iterable:
        if i == level:
            r(iterable, level+1)
    return level
            
@overload
def r(iterable: tuple[float]):
    for i in iterable:
        print(r(iterable, i+1))
    
r(tuple(np.random.))