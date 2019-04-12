

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

    depth_sorted = df[topcol].is_monotonic_increasing
    elevation_sorted = df[topcol].is_monotonic_decreasing

    assert depth_sorted or elevation_sorted, f'Bed sequence `topcol` must be sorted (depth or elev.)'
    if


    assert basecol or thickcol, '`basecol` and `thickcol` cannot both be `None`'

    if basecol :
        assert basecol in df.columns, f'`basecol` {basecol} not present in `df.columns`'
        return df

    pass
