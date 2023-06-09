from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import numpy


include = [numpy.get_include(), 'gravity']
pk = [*setuptools.find_packages('gravity'), 'gravity']

setup(
    ext_modules=cythonize(
        [
            Extension("gravity.constants_cy", sources=["gravity/constants_cy.pyx"], include_dirs=include),
            Extension("gravity.run", sources=["gravity/run.pyx"], include_dirs=include),
        ],
        nthreads=12,
        compiler_directives={'language_level' : "3"},
        annotate=True,
    ),
    zip_safe=False,
    include_dirs=include,
    packages=pk,
)
