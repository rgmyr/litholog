# LithoLog

### Overview

`litholog` is focused on providing a framework to digitize, store, plot, and analyze sedimentary graphic logs (example log shown below).

Graphic logs are the most common way geologists characterize and communicate the composition and variability of clastic sedimentary successions; through a simple drawing, a graphic log imparts complex geological concepts (e.g., the Bouma turbidite sequence or a shoreface parasequence). The term ‘graphic log’ originates from a geologist graphically drawing (i.e., ‘logging’) an outcrop or core; other synonymous terms include measured section and stratigraphic column.

`litholog` is a package-level extension of [agile-geoscience/striplog](https://github.com/agile-geoscience/striplog), with additional features that focus on lithology, and an API that is geared toward facilitating machine learning and quantitative analysis.

<img src="/images/example_log.png" alt="Graphic log example" width="600" />

As you can see above, litholog faithfully reproduces graphic log data, but errors or omissions when digitizing are propagated. Care during digitizing is of the utmost importance, as manual manipulation of litholog data (e.g., grain size) is not recommended.

### Data Structures

The package provides two primary data structures:
- `Bed`
    - stores data from one bed (e.g., top, base, lithology, thickness, grain size, etc).
    - is equivalent to a `striplog.Interval`

- `BedSequence`
    - stores a collection of `Beds` in stratigraphic order
    - is equivalent to a `striplog.Striplog`

### Utilities

Several utilities for working with graphic logs are included with `litholog`:

- transformations for grain-size data from millimeter (mm) to log2 (a.k.a. *Psi*) units, which are far easier to work with than mm.
- calculation of the following metrics at the `BedSequence` level:
    - net-to-gross
    - amalgamation ratio
    - psuedo gamma ray log
    - Hurst statistics (for determining facies clustering)
- default lithology colors for Beds

### Data

The data provided with this demo come from two papers, and all logs were digitized using the Matlab digitizer included with this release.
- 7 logs from Jobe et al. 2012 ([html](https://doi.org/10.1111/j.1365-3091.2011.01283.x), [pdf](https://www.dropbox.com/s/sgzmc1exd5vjd3h/2012%20Jobe%20et%20al%20Sed-%20Climbing%20ripple%20successions%20in%20turbidite%20systems.pdf?dl=0))
- 6 logs from Jobe et al. 2010 ([html](https://doi.org/10.2110/jsr.2010.092), [pdf](https://www.dropbox.com/s/zo12v3ixm86yt7e/2010%20Jobe%20et%20al%20JSR%20-%20Submarine%20channel%20asymmetry.pdf?dl=0)).

#### To-do

- Look into binary save/load. CSV is pretty slow, and pickle creates weird behaviors.
