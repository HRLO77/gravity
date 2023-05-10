this was a project i made for fun

this simulate interactions between N bodies through gravity

I really dont have the energy to explain all this extremely badly written code and math systems


What you need to know is on line #59 in `./code/test.py` (which is what you should probably run)

contains everything you want

```py
# ./code/test.py:53:
    handler.move_timestep(first=5, last=-3, take_part=100, limit=25, skip=10, direction_func=np.median)
```

* The argument `first` is the number of particles closest to any given body, that should be calculated via direct sum (the larger the number, the more accurate the simulation but significantly slower)

* The argument `last` the the last number of particles furtherst from any given body that should be grouped. To cut down on calculations, these particles are found, and certain number of particles closest to them will be treated as one particle, drastically reducing required calculations. The value should be negative, if you want 50 general particles faraway, you should put `-50` and so on.

* The argument `take_part` is related to `last`, `take_part` is how many particles should be rounded to the general faraway bodies from in `last`, so if i have `last=50` and `take_part=800`, then I will have 50 particles, each of which is the median of 800 others particles treated as one.

* The argument `limit` is how many unit of spaces (pixels in this case) should be close to one particle before they are all grouped as one. Because particles group together, and if they are in the exact same area, you can cut down on calculations a lot, and treat them as one.

* The argument `skip` is how many of the last particles you want to skip, it is defauled to `1`, which means you take all the `last` particles without skipping between them, if you have a lot of particle, higher values can help you get a more accurate distribution of particles faraway since it will skip some particles and move closer. This may backfire however if it is too high.