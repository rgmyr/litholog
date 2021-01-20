# LithoLog

### Overview

`litholog` is focused on providing a framework to digitize, store, plot, and analyze sedimentary graphic logs (example log shown below).

Graphic logs are the most common way geologists characterize and communicate the composition and variability of clastic sedimentary successions; through a simple drawing, a graphic log imparts complex geological concepts (e.g., the Bouma turbidite sequence or a shoreface parasequence). The term ‘graphic log’ originates from a geologist graphically drawing (i.e., ‘logging’) an outcrop or core; other synonymous terms include measured section and stratigraphic column.

<img src="/images/example_log_drawing.png" alt="Graphic log as drawn in a field notebook" width="600"/>

<img src="/images/example_log_litholog.png" alt="Graphic log produced by litholog" width="600"/>

`litholog` is a package-level extension of [agile-geoscience/striplog](https://github.com/agile-geoscience/striplog), with additional features that focus on lithology, and an API that is geared toward facilitating machine learning and quantitative analysis.

### Data Structures

The package provides two primary data structures:
- `Bed`
    - stores data from one bed (e.g., top, base, lithology, thickness, grain size, etc).
    - is equivalent to a `striplog.Interval`

- `BedSequence`
    - stores a collection of `Beds` in stratigraphic order
    - is equivalent to a `striplog.Striplog`

### Utilities

Several utilities for working with graphic logs are included:

- transformations for grain-size data from millimeter (mm) to log2 (a.k.a. *Psi*) units, which are far easier to work with than mm.
- calculation of the following metrics at the `BedSequence` level:
    - net-to-gross
    - amalgamation ratio
    - psuedo gamma ray log
    - Hurst statistics (for determining facies clustering)
- default lithology colors for Beds

### Data

The data provided with this demo come from a paper by Zane Jobe et al. ([html](https://doi.org/10.1111/j.1365-3091.2011.01283.x), [pdf](http://www.academia.edu/download/31596179/Jobe_et_al_2012_Sed-_Climbing_ripple_successions_in_turbidite_systems.pdf)), and there are 19 graphic logs in that paper, all of which were digitized using the Matlab digitizer included with this release.

#### To-do

- Look into binary save/load. CSV is pretty slow, and pickle creates weird behaviors.
