

class TableReader():
    """
    Read rows of a csv as `Beds` and return `BedSequence`s.
    I think `fields` will be a dict with certain required+default keys?
    """
    def __init__(self, fields):
        pass


def preprocess_bed_seq(df, topcol, basecol, thickcol, sort='elevation'):
    """
    Infer relationship b/t top + base + thickness, etc. for an individual sequence.
    Must provide either `basecol` or `thickcol` (one of the two may be None).

    TODO: Should probably standardize depth vs. elevation ordering?
    """
    assert topcol in df.columns, f'`topcol` {topcol}  not present in `df`'
    assert basecol or thickcol, '`basecol` and `thickcol` cannot both be `None`'

    # Depth vs. Elevation checks
    depth_sorted = df[topcol].is_monotonic_increasing
    elevation_sorted = df[topcol].is_monotonic_decreasing

    assert depth_sorted or elevation_sorted, f'Bed sequence `topcol` must be sorted (depth or elev.)'

    # TODO: check that if basecol and thickcol both present, they agree
    if basecol:
        assert basecol in df.columns, f'`basecol` {basecol} not present in `df`'
    if thickcol:
        assert thickcol in df.columns, f'`thickcol` {basecol} not present in `df`'

    if depth_sorted:
        assert (df[basecol] >= df[topcol]).all(), f'depth ordering implies all bases >= tops'
    else:
        assert (df[basecol] <= df[topcol]).all(), f'elevation ordering implies all bases <= tops'

    pass
