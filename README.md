This project simulates gravitional interactions between N-bodies


# requirements
install by `py -m pip install -r requirements.txt` and `py -m pip install setuptools -U`

What you need to know is in `./gravity/python_code/test.py`

Simply changing the masses of particles and creating as many bodies as you want, starts a real-time simulation in pygame.

# cython

This is the most recommended way to calculate particle before rendering, pypy is fast, but not nearly as fast as this.

Cython files are in `./gravity/` . If you need to compile them again, run `py cyth.py build_ext --inplace` in `/`

run `py test.py` to start the computing. When ctrl+c is pressed, computing is stopped and the particles collected are dumped in-order in `data.pickle`, along with a detailed last frame in-case you want to pick-up where you left off.

Running `py animate.py` will start a matplotlib animation of the computed data in `data.pickle`.

the cython code is very efficient, producing 1 frame every ~0.00386308702 seconds, which is about ~0.115892611 seconds of calculating to produce one second of rendering (at 30/frames a second, 1000 particles) and computing with direct-sum (highest accuracy)

`test_animation.pickle` Has a pre-loaded simulation, just run `py animate.py` to see it! (requires no installing of compilers, buildtools, compiling or changing paths.)

Enjoy!
