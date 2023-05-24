from setuptools import setup, Extension
import setuptools
from Cython.Build import cythonize
import numpy

setup(
    ext_modules=cythonize([Extension("constants_cy", sources=["code/constants_cy.pyx"], include_dirs=[numpy.get_include(), './code/',])], nthreads=12),
    zip_safe=False, include_dirs=[numpy.get_include(), './code/',], packages=setuptools.find_packages()
)

setup(
    ext_modules=cythonize([Extension("pygame_classes_cy", sources=["code/pygame_classes_cy.pyx"], include_dirs=[numpy.get_include(), './code/',])], nthreads=12),
    zip_safe=False, include_dirs=[numpy.get_include(), './code/',], packages=setuptools.find_packages()
)

setup(
    ext_modules=cythonize([Extension("classes_cy", sources=["code/classes_cy.pyx"], include_dirs=[numpy.get_include(), './code/',])], nthreads=12),
    zip_safe=False, include_dirs=[numpy.get_include(), './code/',], packages=setuptools.find_packages()
)


setup(
    ext_modules=cythonize([Extension("run", sources=["code/run.pyx"], include_dirs=[numpy.get_include(), './code/',])], nthreads=12),
    zip_safe=False, include_dirs=[numpy.get_include(), './code/',], packages=setuptools.find_packages()
)