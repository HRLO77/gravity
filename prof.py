import pstats, cProfile
# from gravity import test
cProfile.runctx("from gravity import test", globals(), locals(), "Profile.prof")

s = pstats.Stats("Profile.prof")
s.strip_dirs().sort_stats("time").print_stats()