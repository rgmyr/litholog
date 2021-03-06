#!/usr/bin/env python3
'''
Seems to work fine, might update later.
'''
import os
from setuptools import find_packages

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

PACKAGE_PATH = os.path.abspath(os.path.join(__file__, os.pardir))
print(PACKAGE_PATH)

setup(name='litholog',
      version='0.1',
      description='File IO, data management, and viz for geological graphic logs/measured sections',
      url='https://github.com/rgmyr/litholog',
      author='Ross Meyer',
      author_email='ross.meyer@utexas.edu',
      packages=find_packages(PACKAGE_PATH),
      install_requires=[
        'numpy>=1.13.0',
        'scipy>=1.5',
        'matplotlib>=3.2',
        'pandas>=1.0',
      ],
      zip_safe=False
)
