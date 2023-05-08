from setuptools import setup
from Cython.Build import cythonize

setup(
    name='classes',
    ext_modules=cythonize("classes.py", nthreads=6, compiler_directives={'language_level' : "3"}),
    zip_safe=False,
)