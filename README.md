this was a project i made for fun

this simulate interactions between N bodies through gravity

I really dont have the energy to explain all this extremely badly written code and math systems


# requirements
install by `py -m pip install -r requirements.txt` and `py -m pip install setuptools -U`

What you need to know is on line #53 in `./gravity/python_code/test.py` (which is what you should probably run)

contains everything you want

```py
# ./gravity/test.py:53:
    handler.move_timestep(first=5, last=-3, take_part=100, limit=25, skip=10, direction_func=np.median)
```

* The argument `first` is the number of particles closest to any given body, that should be calculated via direct sum (the larger the number, the more accurate the simulation but significantly slower)

* The argument `last` the the last number of particles furtherst from any given body that should be grouped. To cut down on calculations, these particles are found, and certain number of particles closest to them will be treated as one particle, drastically reducing required calculations. The value should be negative, if you want 50 general particles faraway, you should put `-50` and so on.

* The argument `take_part` is related to `last`, `take_part` is how many particles should be rounded to the general faraway bodies from in `last`, so if i have `last=50` and `take_part=800`, then I will have 50 particles, each of which is the median of 800 others particles treated as one.

* The argument `limit` is how many unit of spaces (pixels in this case) should be close to one particle before they are all grouped as one. Because particles group together, and if they are in the exact same area, you can cut down on calculations a lot, and treat them as one.

* The argument `skip` is how many of the last particles you want to skip, it is defauled to `1`, which means you take all the `last` particles without skipping between them, if you have a lot of particle, higher values can help you get a more accurate distribution of particles faraway since it will skip some particles and move closer. This may backfire however if it is too high.

Or you can just run test.cmd or test.exe to run the nuitka compiled code (i cant tell the speed difference)
# pypy

I have an unzipped pypy folder because i could not figure out how to install it.

./gravity/code/ has scripts related to computing all the data with pypy, WITHOUT rendering it. After running test.py with pypy, ctrl+c will stop the computing and dump all the data into data.pickle, formatted like `[[int (the number of the frame, lower is closer to first) tuple[particle]]]` the particle class has the data you want (mainly the x and y positions), rendering it is YOUR JOB, not mine.

# cython

This is the most recommended way to calculate particle before rendering, pypy is fast, but not nearly as fast as this.

Cython files are in `./gravity/` . If you need to compile them again, run `py cyth.py build_ext --inplace` in `/`

run `py test.py` to start the computing. When ctrl+c is pressed, computing is stopped and the particles collected are dumped in-order in `data.pickle`

Again, your job to figure out how to render them.

the cython code is very efficient, producing 1 frame every ~0.0770926188 seconds, which is about 2.31 seconds of calculating to produce one second of rendering (at 30/frames a second, 1000 particles) and computing with direct-sum (highest accuracy)

`load.py` Loads the serialized data from `data.pickle`

Enjoy!