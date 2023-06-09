import pstats, cProfile

import pyximport
pyximport.install()

import gravity

cProfile.runctx("from gravity import run", globals(), locals(), "Profile.prof")

s = pstats.Stats("Profile.prof")
s.strip_dirs().sort_stats("time").print_stats()
