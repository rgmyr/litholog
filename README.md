# LithoLog

### Overview

`litholog` is a package-level extension of [agile-geoscience/striplog](https://github.com/agile-geoscience/striplog), with an API and additional features that are geared toward facilitating machine learning experiments and quantitative analysis of stratigraphic log datasets.

### Data Structures

The package provides two primary data structures:
- `Bed(striplog.Interval)`
- `BedSequence(striplog.Striplog)`

### Lithological Utilities

We work a lot with grainsizes, which are more convenient to work with in `log2` (a.k.a. *Psi*) units, rather than the original `mm` measurements.
