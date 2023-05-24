from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import numpy
include = [numpy.get_include(), 'code',]
pk=[*setuptools.find_packages('code'), 'code']

setup(
    ext_modules=cythonize([Extension("code.constants_cy", sources=["code/constants_cy.pyx"], include_dirs=include)], nthreads=12),
    zip_safe=False, include_dirs=include, packages=pk
)

setup(
    ext_modules=cythonize([Extension("code.pygame_classes_cy", sources=["code/pygame_classes_cy.pyx"], include_dirs=include)], nthreads=12),
    zip_safe=False, include_dirs=include, packages=pk
)

setup(
    ext_modules=cythonize([Extension("code.classes_cy", sources=["code/classes_cy.pyx"], include_dirs=include)], nthreads=12),
    zip_safe=False, include_dirs=include, packages=pk
)

setup(
    ext_modules=cythonize([Extension("code.run", sources=["code/run.pyx"], include_dirs=include)], nthreads=12),
    zip_safe=False, include_dirs=include, packages=pk
)