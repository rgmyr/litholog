"""
Notes:
    - Just need top depths/elevations.
"""
import numpy as np
import matplotlib as mpl

from striplog import Striplog, Legend

from graphiclog import Bed
from graphiclog import utils



class BedSequence(Striplog):
    """
    Ordered collection of `Bed` instances. Should we inherit from striplog.Striplog? Probably.

    """
    def __init__(self, list_of_Beds, metadata={}):
        self.metadata = metadata
        Striplog.__init__(self, list_of_Beds)


    @property
    def values(self):
        """
        Get the instance as a 2D array w/ shape (nsamples, nfeatures).
        """
        pairs = zip(self._Striplog__list[:-1], self._Striplog__list[1:])
        assert all(t.compatible_with(b) for t, b in pairs), 'Beds must have compatible data'
        return np.vstack([bed.values for bed in self._Striplog__list])


    @property
    def nsamples(self):
        """
        The number of sample rows in `values`.
        ** Note: len(Striplog) will already give number of beds.
        """
        return self.values.shape[0]

    @property
    def nfeatures(self):
        """
        The number of feature columns in `values`.
        """
        return self.values.shape[1]


    def max_field(self, field):
        """
        Override method from `Striplog`
        """
        return max(filter(None, [iv.max_field(field) for iv in self]))


    def min_field(self, field):
        """
        Override method from `Striplog`
        """
        return min(filter(None, [iv.min_field(field) for iv in self]))


    def get_field(self, field):
        """
        Get 'vertical' array of `field` values
        """
        return np.concatenate(filter(None, [iv[field] for iv in self]))


    def resample_data(self, depth_key, step):
        """
        Resample the data at approximate depth intervals of size `step`.
        `depth_key` can be a `str` (for dict-like bed data) or column index (for array bed data).

        I think we probably want to maintain top/base samples, and sample to the nearest `step` b/t.
        Maybe this could be the default of multiple options? Implement it as the default first though.
        """
        # Note: implement as `Bed` method than can just be mapped over self.__list
        pass


    @classmethod
    def from_dataframe(cls, df,
                      topcol='tops',
                      basecol=None,
                      thickcol=None,
                      component_map=None,
                      datacols=[],
                      metacols=[],
                      metasafe=True):
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
        # Set up & check top/base columns
        assert topcol in df.columns, f'`topcol` {topcol}  not present in `df`'

        assert basecol or thickcol, 'Must specify either `basecol` or `topcol`'
        if basecol:
            assert basecol in df.columns, f'`basecol` {basecol} not present in `df`'
        else:
            assert thickcol in df.columns, f'`thickcol` {thickcol} not present in `df`'
            # TODO: elevation vs depth ordering, might need more specifics here
            df['base'] = df[topcol] - df[thickcol]
            basecol = 'base'

        # Check for data/meta column presence
        missing_data_cols = [c for c in datacols if c not in df.columns]
        assert not missing_data_cols, f'datacols {missing_data_cols} not present in `df`'

        missing_meta_cols = [c for c in metacols if c not in df.columns]
        assert not missing_meta_cols, f'metacols {missing_meta_cols} not present in `df`'

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


    @classmethod
    def from_numpy(self, arr):
        """
        Implement a method to convert numpy (e.g., from GAN) to `BedSequence` instance.
        """
        pass


    def plot(self,
             legend=None,
             fig_width=1.5,
             aspect=10,
             width_field=None,
             depth_field=None,
             wentworth='fine',
             ax=None,
             **kwargs):
        """
        Plot as a `Striplog` of `Bed`s.

        Might need additional arg to specify Wentworth stuff? Can we assume this will *only* be used for grainsize?
        """
        if legend is None:
            legend = Legend.random(self.components)

        if ax is None:
            return_ax = False
            fig = plt.figure(figsize=(fig_width, aspect*fig_width))
            ax = fig.add_axes([0.35, 0.05, 0.6, 0.95])
        else:
            return_ax = True

        if width_field:
            min_width = min(bed.min_field(width_field) for bed in self.__list if bed[width_field] is not None)
            max_width = max(bed.max_field(width_field) for bed in self.__list if bed[width_field] is not None)
            ax.set_xlim([0, max_width-min_width])

        patches = []
        for bed in self.__list:
            patches.append(
                bed.as_patch(legend, width_field, depth_field,
                             min_width, max_width, **kwargs)
            )

        if return_ax:
            return ax




class Dataset():
    """
    Collection of (optionally grouped) `BedSequences`. Maybe this is just part of modeling project?
    """
    def __init__(self, table):
        pass

    @classmethod
    def from_csv(self, fpath):
        # somehow should handle the loading and coercing
        pass

    def fold_generator(self):
        pass
