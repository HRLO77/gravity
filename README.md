this was a project i made for fun

this simulate interactions between N bodies through gravity

I really dont have the energy to explain all this extremely badly written code and math systems


What you need to know is on line #59 in `./code/test.py` (which is what you should probably run)

contains everything you want

```py
# ./code/test.py:59:
    handler.move_timestep(first=20, last=-8, take_part=10, direction_func=statistics.median_grouped, limit=5)
```

* The argument `first` is the number of particles closest to any given body, that should be calculated via direct sum (the larger the number, the more accurate the simulation but significantly slower)

* The argument `last` the the last number of particles furtherst from any given body that should be grouped. To cut down on calculations, these particles are found, and certain number of particles closest to them will be treated as one particle, drastically reducing required calculations. The value should be negative, if you want 50 general particles faraway, you should put `-50` and so on.

* The argument `take_part` is related to `last`, `take_part` is how many particles should be rounded to the general faraway bodies from in `last`, so if i have `last=50` and `take_part=800`, then I will have 50 particles, each of which is the median of 800 others particles treated as one.

* The argument `limit` is the very last one, it is how many unit of spaces (pixels in this case) should be close to one particle before they are all grouped as one. Because particles group together, and if they are in the exact same area, you can cut down on calculations a lot, and treat them as one.