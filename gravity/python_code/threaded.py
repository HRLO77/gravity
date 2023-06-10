import numpy as np

class test:
    
    def __init__(self, j) -> None:
        self.j = j
        
    def __hash__(self, __value) -> int:
        return hash(self.j)
    
k: np.ndarray[test] = np.array([test('k')])