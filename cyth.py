from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import numpy
import os
<<<<<<< HEAD
import distutils
distutils
=======
from numpy import distutils
(distutils.__file__)
>>>>>>> 541eb1e03c16e7c8a337b2ad0a256db42bcaebf2
os.environ['CC'] = 'clang-cl'  # following is for compilation with clang
os.environ['LDSHARED'] = 'clang -shared'
os.environ['CXX'] = 'clang++'
include = [numpy.get_include(), 'gravity']
pk=[*setuptools.find_packages('gravity'), 'gravity']
cd = {'language_level' : "3"}
args = ['/O2', '/fp:fast', '/Qfast_transcendentals']
setup(
<<<<<<< HEAD
    ext_modules=cythonize([Extension("gravity.constants_cy", sources=["gravity/constants_cy.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, show_all_warnings=True),
=======
    ext_modules=cythonize([Extension("gravity.constants_cy", sources=["gravity/constants_cy.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd),
>>>>>>> 541eb1e03c16e7c8a337b2ad0a256db42bcaebf2
    zip_safe=False, include_dirs=include, packages=pk
)

# setup(
#     ext_modules=cythonize([Extension("gravity.pygame_classes_cy", sources=["gravity/pygame_classes_cy.pyx"], include_dirs=include)], nthreads=12, compiler_directives=cd),
#     zip_safe=False, include_dirs=include, packages=pk
# )

# setup(
#     ext_modules=cythonize([Extension("gravity.classes_cy", sources=["gravity/classes_cy.pyx"], include_dirs=include)], nthreads=12, compiler_directives=cd),
#     zip_safe=False, include_dirs=include, packages=pk
# )

setup(
<<<<<<< HEAD
    ext_modules=cythonize([Extension("gravity.run", sources=["gravity/run.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, annotate=True, show_all_warnings=True),
=======
    ext_modules=cythonize([Extension("gravity.run", sources=["gravity/run.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, annotate=True),
>>>>>>> 541eb1e03c16e7c8a337b2ad0a256db42bcaebf2
    zip_safe=False, include_dirs=include, packages=pk
)

setup(
<<<<<<< HEAD
    ext_modules=cythonize([Extension("animate", sources=["animate.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, show_all_warnings=True),
=======
    ext_modules=cythonize([Extension("animate", sources=["animate.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd),
>>>>>>> 541eb1e03c16e7c8a337b2ad0a256db42bcaebf2
    zip_safe=False, include_dirs=include
)