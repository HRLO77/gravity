# gravity

This project simulates gravitional interactions between N-bodies


# requirements

install by `py -m pip install -r requirements.txt` and `py -m pip install setuptools -U`

# realtime rendering

What you need to perform realtime rendering is in `./gravity/python_code/main.py`

Simply change the masses of particles and creating as many bodies as you want. Starts a real-time simulation in pygame.

# cython

This is the most recommended way to calculate particle before rendering, pypy is fast, but not nearly as fast as this.

Cython files are in `./gravity/` . If you need to compile them again, run `py cyth.py build_ext --inplace` in `/`

For windows users, if you wish to compile using clang, you need to install the [LLVM toolchain](https://github.com/llvm/llvm-project/releases/tag/llvmorg-16.0.0) and visual studio, with windows SDKS, python development, and windows applications.

Then, run `py cyth.py build_ext --inplace` in `/` to compile all the files. After this, run this command (replace USER with your user) ```python
clang -Ofast -ffast-math -DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION -mtune=native -march=native -fapprox-func -fno-honor-infinities -fno-honor-nans -cl-mad-enable -cl-no-signed-zeros -ffinite-loops -cl-fast-relaxed-math -shared -L "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x64" -L "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64" -L "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.36.32532\lib\x64" -L "C:\Program Files\Python311\libs" -IC:\Users\USER\AppData\Roaming\Python\Python311\site-packages\numpy\core\include "-IC:\Program Files\Python311\Include" -Igravity  "-IC:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.36.32532\include" "-IC:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.36.32532\ATLMFC\include" "-IC:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\VS\include" "-IC:\Program Files (x86)\Windows Kits\10\include\10.0.22621.0\ucrt" "-IC:\Program Files (x86)\Windows Kits\10\include\10.0.22621.0\um" "-IC:\Program Files (x86)\Windows Kits\10\include\10.0.22621.0\shared" "-IC:\Program Files (x86)\Windows Kits\10\include\10.0.22621.0\winrt"  "-IC:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\include\um" "-g3" --output="C:\Users\USER\OneDrive - Hamilton Wentworth District School Board\Desktop\python\gravity\build\lib.win-amd64-cpython-311\gravity\run.cp311-win_amd64.pyd" gravity/run.c
```

* *Note*: clang doesn't like some cython generated complex math code, you can simply comment that out to continue with compiliation.

After this, copy `.\build\lib.win-amd64-cpython-311\gravity\run.cp311-win_amd64.pyd` to `./gravity` and you're finished!

run `py main.py` to start the computing. When ctrl+c is pressed, computing is stopped and the particles collected are dumped in-order in `data.pickle`, along with a detailed last frame in-case you want to pick-up where you left off.

Running `py start_animate.py` will start a matplotlib animation or create a gif of the computed data in `data.pickle`.

Actual animation cythonized code is in `animate.pyx`.

the cython code is very efficient, producing 1 frame every ~0.0027647453 seconds, which is about ~0.082942359 seconds of calculating to produce one second of rendering (at 30/frames a second, 1000 particles) and computing with direct-sum (highest accuracy)

`test_animation.pickle` Has a pre-loaded simulation, just run `py animate.py` to see it! (requires no installing of compilers, buildtools, compiling or changing paths.)

Enjoy!

## Issues

* Cython is not natively supported for compilition with python on platform NT, this should be fixed in 3.12. But until then MSVC should work fine.

* Due to the cython code being direct sum (O(n^2) complexity), it relies on simply being fast. If you want it to work fast even with very large numbers of bodies, implementing other algorithms such as barnes-hut (O(log n) complexity) will fix this.
