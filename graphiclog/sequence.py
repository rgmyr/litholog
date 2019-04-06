

"""
Notes:
    - Just need top depths/elevations.
"""
import numpy as np
import matplotlib as mpl

from striplog import Striplog, Legend

from depstrat.graphiclog import utils


class TableReader():
    """
    Read rows of a csv as `Beds` and return `BedSequence`s.
    I think `fields` will be a dict with certain required+default keys?
    """
    def __init__(self, fields):
        pass


class BedSequence(Striplog):
    """
    Ordered collection of `Bed` instances. Should we inherit from striplog.Striplog? Probably.

    """
    def __init__(self, list_of_Beds):
        Striplog.__init__(list_of_Beds)


    @property
    def values(self):
        """
        Get the instance as a 2D array w/ shape (nsamples, nfeatures).
        """
        assert all(t._compatible_with(b) for t, b in zip(self.__list, self.__list[1:])), 'Beds must have compatible data'
        return np.vstack([bed.values for bed in self.__list])

    @property
    def nsamples(self):
        """
        Return number of sample rows in `values`.
        ** Note: len(Striplog) will already give number of beds.
        """
        return self.values.shape[0]

    @property
    def nfeatures(self):
        """
        Return number of feature columns in `values`.
        """


    @classmethod
    def from_dataframe(self, df, datacols=None, metacols=None, component_map=None):
        """
        Create an instance from a pd.DataFrame or subclass (e.g., a GroupBy object)

        Parameters
        ----------
        df : pd.DataFrame or subclass
            Table from which to create `list_of_Beds`.
        datacols : list(str), optional
            Columns to use as `Bed` data. Should reference numeric columns only.
        metacols : list(str), optional
            Columns to read into `metadata` dict attribute. Should reference columns with a single unique value?
        component_map : tuple(str, func), optional
            Function that maps values of a column to a primary striplog.Component for individual Beds.
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
