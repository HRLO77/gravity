from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import numpy
import os
# os.environ['CC'] = 'clang-cl'  # following is for compilation with clang
# os.environ['LDSHARED'] = 'clang -shared'
# os.environ['CXX'] = 'clang++'
include = [numpy.get_include(), 'gravity']
pk=[*setuptools.find_packages('gravity'), 'gravity']
cd = {'language_level' : "3"}

# args = ['/O2', '/fp:fast', '/Qfast_transcendentals'] # args for MSVC

# args = ['-Ofast', '-ffast-math', '-fno-signed-zeros', '-faggressive-loop-optimizations', '-fcaller-saves', '-mtune=native', '-march=native', '-ffinite-loops', '-shared', '-DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION'] # args for GCC

# args = ['-Ofast', '-ffast-math', '-DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION', '-mtune=native', '-march=native', '-fapprox-func', '-fno-honor-infinities', '-fno-honor-nans', '-cl-mad-enable', '-cl-no-signed-zeros', '-ffinite-loops', '-cl-fast-relaxed-math', '-shared'] # args for clang

setup(
    ext_modules=cythonize([Extension("gravity.constants_cy", sources=["gravity/constants_cy.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, show_all_warnings=True),
    zip_safe=False, include_dirs=include, packages=pk
)
# setup(\
#     ext_modules=cythonize([Extension("gravity.pygame_classes_cy", sources=["gravity/pygame_classes_cy.pyx"], include_dirs=include)], nthreads=12, compiler_directives=cd),
#     zip_safe=False, include_dirs=include, packages=pk
# )

# setup(
#     ext_modules=cythonize([Extension("gravity.classes_cy", sources=["gravity/classes_cy.pyx"], include_dirs=include)], nthreads=12, compiler_directives=cd),
#     zip_safe=False, include_dirs=include, packages=pk
# )

setup(
    ext_modules=cythonize([Extension("gravity.run", sources=["gravity/run.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, annotate=True, show_all_warnings=True),
    zip_safe=False, include_dirs=include, packages=pk
)

setup(
    ext_modules=cythonize([Extension("animate", sources=["animate.pyx"], include_dirs=include, extra_compile_args=args)], nthreads=12, compiler_directives=cd, show_all_warnings=True),
    zip_safe=False, include_dirs=include
)
