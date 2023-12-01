# gravity

This project simulates gravitional interactions between N-bodies


# requirements

install by `py -m pip install -r requirements.txt` and `py -m pip install setuptools -U`

# realtime rendering

What you need to perform realtime rendering is in `./gravity/python_code/main.py`

Simply change the masses of particles and creating as many bodies as you want. Starts a real-time simulation in pygame.

# cython

This is the most recommended way to calculate particle before rendering, pypy is fast, but not nearly as fast as this.

Go to `./cyth.py` to enable the arguments that you wish to use based on your compiler!

Cython files are in `./gravity/` . If you need to compile them again, run `py cyth.py build_ext --inplace` in `/`

run `py main.py` to start the computing. When ctrl+c is pressed, computing is stopped and the particles collected are dumped in-order in `data.pickle`, along with a detailed last frame in-case you want to pick-up where you left off.

Running `py start_animate.py` will start a matplotlib animation or create a video of the computed data in `data.pickle`.

This cython code calculates body motions using direct-sum newtonion gravity, and merges bodies based on their roche limit.

Enjoy!

## Issues

* Clang is not natively supported for compilition with python on platform NT, this should be fixed in 3.12. But until then MSVC should work fine.

* Due to the cython code being direct sum (O(n^2) complexity), it relies on simply being fast. If you want it to work fast even with very large numbers of bodies, implementing other algorithms such as barnes-hut (O(log n) complexity) will fix this.

## pre-compiled binaries

pre-compiled binaries for x64 windows and linux platforms can be found in `./binaries`, simply copy the DLLs to their locations and run `python main.py`.