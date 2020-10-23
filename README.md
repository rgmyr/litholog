# LithoLog

### Overview

`litholog` is a package-level extension of [agile-geoscience/striplog](https://github.com/agile-geoscience/striplog), with additional features that focus on lithology, and an API that is geared toward facilitating machine learning and quantitative analysis.

### 


### Data Structures

The package provides two primary data structures:
- `Bed(striplog.Interval)`
- `BedSequence(striplog.Striplog)`

### Lithological Utilities

We work a lot with grainsizes, which are more convenient to work with in `log2` (a.k.a. *Psi*) units, rather than the original `mm` measurements.


#### To-do

- Look into binary save/load. CSV is pretty slow, and pickle creates weird behaviors.
