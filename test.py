from code import run
import pickle
with open('data.pickle', 'wb') as file:
    push = run.particles
    pickle.dump(list(push), file)
print(f'{len(run.particles)} Frames captured.')