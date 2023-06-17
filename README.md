This project simulates gravitional interactions between N-bodies


# requirements
install by `py -m pip install -r requirements.txt` and `py -m pip install setuptools -U`

What you need to know is in `./gravity/python_code/test.py`

Simply changing the masses of particles and creating as many bodies as you want, starts a real-time simulation in pygame.

# cython

This is the most recommended way to calculate particle before rendering, pypy is fast, but not nearly as fast as this.

Cython files are in `./gravity/` . If you need to compile them again, run `py cyth.py build_ext --inplace` in `/`

run `py test.py` to start the computing. When ctrl+c is pressed, computing is stopped and the particles collected are dumped in-order in `data.pickle`, along with a detailed last frame in-case you want to pick-up where you left off.

Running `py start_animate.py` will start a matplotlib animation or create a gif of the computed data in `data.pickle`.

Actual animation cythonized code is in `animate.pyx`.

the cython code is very efficient, producing 1 frame every ~0.00386308702 seconds, which is about ~0.115892611 seconds of calculating to produce one second of rendering (at 30/frames a second, 1000 particles) and computing with direct-sum (highest accuracy)

`test_animation.pickle` Has a pre-loaded simulation, just run `py animate.py` to see it! (requires no installing of compilers, buildtools, compiling or changing paths.)

Enjoy!


## Issues

* When computing with cython, all data is dumped as 16 bit (half precision) floats to save space, but needs to be loaded as 32 bit (full precision) floats to be stored in a memoryview for index. This will take up *twice* as much memory than needed with no benefit when rendering.

* Since positions are stored as single precision floats when computing in cython, any values above 0xFFFF and less than -0xFFFF will simply just not show the positions when rendering, this problem can be delayed by using `double` instead of `float`, but will take up twice as much memory

* Cython cannot be compiled with clang on platform NT, this should be fixed in 3.12. But until then MSVC should work fine.

* Due to the cython code being direct sum (O(n^2) complexity), it relies on simply being fast. If you want it to work fast even with very large numbers of bodies, implementing other algorithms such as barnes-hut (O(log n) complexity) will fix this.