"""
IO classes & functions
"""

import numpy as np


class TableReader():
    """
    Read rows of a csv as `Beds` and return `BedSequence`s.
    I think `fields` will be a dict with certain required+default keys?
    """
    def __init__(self, fields):
        pass


def preprocess_dataframe(df, topcol, basecol=None, thickcol=None, eps=1e-3):
    """
    Check for position order + consistency in `df`, return preprocessed DataFrame.

    This doesn't check for all possible inconsistencies, just the most obvious ones.
    """
    assert topcol in df.columns, f'`topcol` {topcol}  not present in `df`'

    assert basecol or thickcol, 'Must specify either `basecol` or `topcol`'

    elev_sorted = df.sort_values(topcol, ascending=False)
    depth_sorted = df.sort_values(topcol, ascending=True)

    if basecol:
        assert basecol in df.columns, f'`basecol` {basecol} not present in `df`'
        if (df[topcol] > df[basecol]).all():
            return elevation_sorted
        elif (df[topcol] < df[basecol]).all():
            return depth_sorted
        else:
            raise ValueError('Dataframe has inconsistent top/base conventions')

    else:
        assert thickcol in df.columns, f'`thickcol` {thickcol} not present in `df`'

        elev_bases = (elev_sorted[topcol] - elev_sorted[thickcol]).values
        elev_gap = np.abs(elev_bases[:-1]-elev_sorted[topcol].values[1:]).sum()
        print(f'elev_gap: {elev_gap}')

        depth_bases = (depth_sorted[topcol] + depth_sorted[thickcol]).values
        depth_gap = np.abs(depth_bases[:-1]-depth_sorted[topcol].values[1:]).sum()
        print(f'depth_gap: {depth_gap}')

        min_total_gap = min(elev_gap, depth_gap)
        if min_total_gap > eps*df.shape[0]:
            raise UserWarning('Check that thicknesses are consistent! '
                             f'Total gap: {min_total_gap}, Allowed: {eps*df.shape[0]}')
        elif elev_gap < depth_gap:
            elev_sorted['bases'] = elev_bases
            return elev_sorted
        else:
            depth_sorted['bases'] = depth_bases
            return depth_sorted
