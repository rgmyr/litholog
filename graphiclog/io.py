"""
IO classes & functions
"""
import operator
from abc import abstractmethod

import numpy as np
import pandas as pd

from graphiclog import utils


def check_order(df, topcol, basecol, raise_error=True):
    """
    Check that all rows are either depth ordered or elevation_ordered.
    Returns 'elevation' or 'depth'.
    """
    assert basecol in df.columns, f'`basecol` {basecol} not present in {df.columns}'

    if (df[topcol] > df[basecol]).all():
        return 'elevation'
    elif (df[topcol] < df[basecol]).all():
        return 'depth'
    elif raise_error:
        raise ValueError('Dataframe has inconsistent top/base conventions')
    else:
        return None


def check_samples(df, depthcol, valuecol):
    """
    Check that `depth_col` and `sample_col` have equal number of entries per bed,
    (and that `depths` fall between `topcol` and `basecol`?)

    Returns
    -------
    good : bool
        True if sizes match in all rows, False otherwise.
    """
    dsizes = df[depthcol].apply(utils.safelen)
    vsizes = df[valuecol].apply(utils.safelen)

    if (dsizes == vsizes).all():
        return True
    else:
        return False


def check_thicknesses(df, topcol, thickcol, order, basecol='bases', tol=1e-3):
    """
    Check that gap between tops and adjacent bases implied by 'th' are consistent and small.

    Returns
    -------
    (df, good) : (DataFrame, bool)
        `df` has new `basecol` added with implied base positions
        `good` is `True` if the average gap < `tol`, else `False`
    """
    assert order in {'elevation', 'depth'}, f'{order} not a valid `order`'
    assert thickcol in df.columns, f'{thickcol} not in {df.columns}'

    op = operator.sub if order is 'elevation' else operator.add

    bases = op(df[topcol], df[thickcol]).values

    gap = np.abs(bases[:-1] - df[topcol].values[1:]).sum()

    df.loc[:, basecol] = bases

    within_tolerance = True if gap <= tol*bases.size else False

    return df, within_tolerance


def preprocess_dataframe(df, topcol, basecol=None, thickcol=None, tol=1e-3):
    """
    Check for position order + consistency in `df`, return preprocessed DataFrame.

    This doesn't check for all possible inconsistencies, just the most obvious ones.
    """
    assert topcol in df.columns, f'`topcol` {topcol}  not present in {df.columns}'

    assert basecol or thickcol, 'Must specify either `basecol` or `topcol`'

    elev_sorted = df.sort_values(topcol, ascending=False)
    depth_sorted = df.sort_values(topcol, ascending=True)

    if basecol:
        order = check_order(df, topcol, basecol)
        return elev_sorted if order is 'elevation' else depth_sorted

    else:
        elev_sorted, elev_good = check_thicknesses(elev_sorted, topcol, thickcol,
                                                  'elevation', basecol='bases', tol=tol)
        if elev_good:
            return elev_sorted

        depth_sorted, depth_good = check_thicknesses(depth_sorted, topcol, thickcol,
                                                    'depth', basecol='bases', tol=tol)
        if depth_good:
            return depth_sorted

        raise UserWarning('Check that thicknesses are consistent!')
