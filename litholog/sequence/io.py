"""
IO classes & functions
"""
import operator
from abc import ABC, abstractmethod

import numpy as np
import pandas as pd

from litholog import Bed, utils


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

    assert basecol or thickcol, 'Must specify either `basecol` or `thickcol`'

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



class SequenceIOMixin(ABC):
    """
    Defines the IO interface for `BedSequence`.
    """
    @classmethod
    def from_dataframe(cls, df,
                      topcol='tops',
                      basecol=None,
                      thickcol=None,
                      component_map=None,
                      datacols=[],
                      metacols=[],
                      metasafe=True,
                      tol=1e-3):
        """
        Create an instance from a pd.DataFrame or subclass (e.g., a GroupBy object).
        Must provide `topcol` and one of `basecol` or `thickcol`.

        Parameters
        ----------
        df : pd.DataFrame or subclass
            Table from which to create `list_of_Beds`.
        topcol : str
            Name of top depth/elevation column. Must be present. Default='top'.
        basecol, thickcol: str
            Either provide a base depth/elevation column, or a thickness column. Must provide at least one.
        component_map : tuple(str, func), optional
            Function that maps values of a column to a primary `striplog.Component` for individual Beds.
            TODO: if `func` is a str with 'wentworth', maybe just map using grainsize bins?
        datacols : list(str), optional
            Columns to use as `Bed` data. Should reference numeric columns only.
        metacols : list(str), optional
            Columns to read into `metadata` dict attribute. Should reference columns with a single unique value?
        metasafe : bool, optional
            If True, enforce that df[metacols] have a single unique value per-column. Otherwise attach all unique values.
        """
        # Check for data/meta column presence
        missing_data_cols = [c for c in datacols if c not in df.columns]
        assert not missing_data_cols, f'datacols {missing_data_cols} not present in `df`'

        missing_meta_cols = [c for c in metacols if c not in df.columns]
        assert not missing_meta_cols, f'metacols {missing_meta_cols} not present in `df`'

        # Preprocess the data
        try:
            df = preprocess_dataframe(df, topcol, basecol=basecol, thickcol=thickcol, tol=tol)
        except Exception as e:
            print('Problem with:', df)
            raise(e)

        basecol = basecol or 'bases'

        metadata = {}
        for metacol in metacols:
            meta_values = df[metacol].unique()
            if metasafe:
                assert len(meta_values) == 1, f'`metacol` {metacol} has more than one unique value: {meta_values}'
            metadata[metacol] = meta_values[0]

        list_of_Beds = []
        for _, row in df.iterrows():
            if component_map:
                field, field_fn = component_map
                component = field_fn(row[field])
                bed = Bed(row[topcol], row[basecol], row[datacols], components=[component])
            else:
                bed = Bed(row[topcol], row[basecol], row[datacols])
            list_of_Beds.append(bed)

        return cls(list_of_Beds, metadata=metadata)


    #def to_dataframe(self):

    @classmethod
    def from_numpy(self, arr, other=None, keys=None, split_key=None, component_map=None):
        """
        Implement a method to convert numpy (e.g., from GAN) to `BedSequence` instance.

        Use keys from `other`, or provide list of `keys`.
        Provide a `component_map` to group samples into `Bed`s.
        """
        pass
