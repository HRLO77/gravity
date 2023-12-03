from gravity import run
run.run()
from numpy import array
import pickle
# if end:
#     with open('data.pickle', 'rb') as f:
#         prev_dat = pickle.load(f)[0]
#     BODIES = prev_dat.shape[0], prev_dat.shape[1], prev_dat.shape[2]
#     with open('data.pickle', 'wb') as f:
#         pickle.dump((array(prev_dat.tolist()+run.particles.tolist()), run.session), f)
# else:
with open('data.pickle', 'wb') as f:
    pickle.dump((run.particles, run.session), f)
print(f'{len(run.particles)} Frames captured.')