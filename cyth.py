from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import os
# os.environ['CC'] = 'clang-cl'  # following is for compilation with clang
# os.environ['LDSHARED'] = 'clang -shared'
# os.environ['CXX'] = 'clang++'

include = ['gravity']
if os.path.isdir('/MinGW/bin/'):
    include.append('/MinGW/bin/')
pk=[*setuptools.find_packages('gravity'), 'gravity']
cd = {'language_level' : "3"}

# args = ['/O2', '/fp:fast', '/Qfast_transcendentals', '/std:c++latest']  # args for MSVC

args = ['-Ofast', '-funsafe-math-optimizations', '-mtune=native', '-march=native', '-ffinite-math-only', '-freciprocal-math', '-shared', '-DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION', '-std=c++20', '-fno-trapping-math', '-fno-math-errno', '-fno-signed-zeros', '-falign-loops'] # args for GCC


# args = ['-Ofast', '-ffast-math', '-DNPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION', '-mtune=native', '-march=native', '-fapprox-func', '-fno-honor-infinities', '-fno-honor-nans', '-cl-mad-enable', '-cl-no-signed-zeros', '-ffinite-loops', '-cl-fast-relaxed-math', '-shared', '-std=c++20', '-fno-signed-zeros', '-falign-loops'] # args for clang

link_args = ['-static-libgcc', '-static-libstdc++', '-W','-Bstatic','--whole-file', '-lpthread']


setup(
    ext_modules=cythonize([Extension("gravity.constants_cy", sources=["gravity/constants_cy.pyx"], include_dirs=include, extra_compile_args=args, extra_link_args=link_args)], nthreads=12, compiler_directives=cd, show_all_warnings=True, ),
    zip_safe=False, include_dirs=include, packages=pk,
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
    ext_modules=cythonize([Extension("gravity.run", sources=["gravity/run.pyx"], include_dirs=include, extra_compile_args=args, extra_link_args=link_args)], nthreads=12, compiler_directives=cd, annotate=True, show_all_warnings=True, ),
    zip_safe=False, include_dirs=include, packages=pk
)