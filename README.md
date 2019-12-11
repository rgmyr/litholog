# GraphicLog

### Overview

`graphiclog` is a package-level extension of [striplog](https://github.com/agile-geoscience/striplog), with the interface and additional features geared toward facilitating machine learning experiments and quantitative analysis of stratigraphic log datasets.

### Data Structures

The package provides two objects:
- `Bed(striplog.Interval)`
- `BedSequence(striplog.Striplog)`

### Lithological Utilities

We work a lot with grainsize, which are usually more convenient in `log2` or *Psi* units, than the original `mm` measurements.
