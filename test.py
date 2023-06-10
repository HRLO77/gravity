from gravity import run
import pickle
run.particles.dump('data.pickle')
print(f'{len(run.particles)} Frames captured.')
