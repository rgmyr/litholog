.. litholog documentation master file, created by
   sphinx-quickstart on Mon Jan 18 19:37:27 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to litholog's documentation!
====================================
``litholog`` is focused on providing a framework to digitize, store, plot, and analyze sedimentary graphic logs (example log shown below).

Graphic logs are the most common way geologists characterize and communicate the composition and variability of clastic sedimentary successions; through a simple drawing, a graphic log imparts complex geological concepts (e.g., the Bouma turbidite sequence or a shoreface parasequence). The term ‘graphic log’ originates from a geologist graphically drawing (i.e., ‘logging’) an outcrop or core; other synonymous terms include measured section and stratigraphic column.

``litholog`` is a package-level extension of `agile-geoscience/striplog <https://github.com/agile-geoscience/striplog/>`_, with additional features that focus on lithology, and an API that is geared toward facilitating machine learning and quantitative analysis.

The package provides two primary data structures:

* ``Bed``, which stores data from one lithologic bed or unit (e.g., top, base, lithology, thickness, grain size, etc). ``Bed`` is equivalent to a ``striplog.Interval``
* ``BedSequence``, which stores a collection of ``Beds`` in stratigraphic order (either elevation or depth order). ``BedSequence`` is equivalent to a ``striplog.Striplog``

Utilities
====================================
Several utilities for working with graphic logs are included with litholog:

* default lithology colors for Beds that can be easily modified
* transformations for grain-size data from millimeter (mm) to log2 (a.k.a. *psi*) units, which are far easier to work with than mm.
* calculation of the following metrics at the BedSequence level:

  * net-to-gross
  * amalgamation ratio
  * psuedo gamma ray log
  * Hurst statistics (for determining facies clustering)

Data
====================================
The data provided with this demo come from two papers, and all logs were digitized using the Matlab digitizer included with this release.

* 7 logs from Jobe et al. 2012 (`html <https://doi.org/10.1111/j.1365-3091.2011.01283.x>`_, `pdf <https://www.dropbox.com/s/sgzmc1exd5vjd3h/2012%20Jobe%20et%20al%20Sed-%20Climbing%20ripple%20successions%20in%20turbidite%20systems.pdf?dl=0>`_).
* 6 logs from Jobe et al. 2010 (`html <https://doi.org/10.2110/jsr.2010.092>`_, `pdf <https://www.dropbox.com/s/zo12v3ixm86yt7e/2010%20Jobe%20et%20al%20JSR%20-%20Submarine%20channel%20asymmetry.pdf?dl=0>`_).

====================================

.. toctree::
   :maxdepth: 4
   :caption: Tutorials:

   litholog_basics
   litholog_demo_data
   source/modules

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
