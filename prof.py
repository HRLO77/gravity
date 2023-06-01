import pstats, cProfile

import pyximport
pyximport.install()

import code

cProfile.runctx("from code import run", globals(), locals(), "Profile.prof")

s = pstats.Stats("Profile.prof")
s.strip_dirs().sort_stats("time").print_stats()