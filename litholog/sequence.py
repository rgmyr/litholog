"""
Notes:
    - Just need top depths/elevations.
"""
import numpy as np
from math import floor, ceil
import matplotlib.pyplot as plt

from striplog import Striplog, Legend

from litholog import Bed
from litholog import io, utils
from litholog.wentworth import wentworth_scale_fine, wentworth_scale_coarse



class BedSequence(Striplog):
    """
    Ordered collection of ``Bed`` instances.
    """
    def __init__(self, list_of_Beds, metadata={}):
        """
        Parameters
        ----------
        list_of_Beds : list(``litholog.Bed``)
            A list containing the Bed(s) comprising the sequence.
        metadata : dict, optional
            Any additional metadata about the sequence as a whole.
        """
        self.metadata = metadata
        Striplog.__init__(self, list_of_Beds)


    @property
    def values(self):
        """
        Get the instance as a 2D array w/ shape (``nsamples``, ``nfeatures``).
        """
        return self.get_values()

    def get_values(self, exclude_keys=[]):
        """
        Getter for ``values`` that allows dropping ``exclude_keys`` (e.g., sample depths) from array
        """
        pairs = zip(self[:-1], self[1:])
        assert all(t.compatible_with(b) for t, b in pairs), 'Beds must have compatible data'
        vals = [bed.get_values(exclude_keys=exclude_keys) for bed in self]
        return np.vstack(vals)


    @property
    def interfaces(self):
        """
        Get all pairs of adjacent Beds.
        """
        return zip(self[:-1], self[1:])

    @property
    def net_to_gross(self):
        """
        Returns (total thickness of 'sand' Beds) / (total thickness of all Beds)
        """
        is_sand = lambda bed: True if bed.lithology == 'sand' else False
        not_missing = lambda bed: False if bed.lithology == 'missing' else True

        sand_th = sum([bed.thickness for bed in filter(is_sand, self)])
        total_th = sum([bed.thickness for bed in filter(not_missing, self)])

        return sand_th / total_th


    @property
    def amalgamation_ratio(self):
        """
        1. dont count mud on mud contacts
        2. find sand on sand contacts
        3. divide sand-on-sand contacts by total number of contacts
        """
        total_contacts, sand_contacts = 0, 0
        for upper, lower in self.interfaces:
            if upper.lithology == lower.lithology == 'sand':
                sand_contacts += 1
            elif upper.lithology == lower.lithology == 'mud':
                continue
            total_contacts += 1

        return sand_contacts / total_contacts


    @property
    def nsamples(self):
        """
        The number of sample rows in ``values``.
        NOTE: ``len(striplog.Striplog)`` will already give number of beds.
        """
        return self.values.shape[0]

    @property
    def nfeatures(self):
        """
        The number of columns in ``values``.
        """
        return self.values.shape[1]


    def max_field(self, field):
        """
        Override method from ``striplog.Striplog`` to account for iterable ``Bed`` data.
        """
        return max(filter(None, [iv.max_field(field) for iv in self]))


    def min_field(self, field):
        """
        Override method from ``striplog.Striplog`` to account for iterable ``Bed`` data.
        """
        return min(filter(None, [iv.min_field(field) for iv in self]))


    def get_field(self, field, default_value=0.0):
        """
        Get 'vertical' array of ``field`` values
        """
        vals = [iv[field] for iv in self]
        vals = [default_value] if len(vals) == 0 else vals
        try:
            return np.concatenate(vals)
        except ValueError:
            return np.array(vals)


    def reduce_field(self, field, fn):
        """
        Apply ``fn`` to the output of ``get_field(field)``
        """
        result = fn(self.get_field(field))
        if not hasattr(result, '__iter__'):
            result = [result]
        return np.array(result)


    def reduce_fields(self, field_fn_dict):
        """
        Return 1D array, result of applying `fn` values to `field` keys.
        """
        try:
            vals = [self.reduce_field(field, fn) for field, fn in field_fn_dict.items()]
        except Exception as e:
            print(f'Error reducing fields for: {self.metadata}')
            raise(e)

        try:
            return np.concatenate(vals)
        except ValueError as ve:
            print([(v, np.shape(v)) for v in vals])
            raise(ve)


    def resample_data(self, depth_key, step, kind='linear'):
        """
        Resample the data at approximate depth intervals of size `step`.
        `depth_key` can be a `str` (for dict-like bed data) or column index (for array bed data).

        I think we probably want to maintain top/base samples, and sample to the nearest `step` b/t.
        Maybe this could be the default of multiple options? Implement it as the default first though.

        NOTE: We could return a new instance rather than modify inplace, since it's hard to undo.
        """
        for iv in self:
            iv.resample_data(depth_key, step, kind=kind)
        return self.values


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
        df = io.preprocess_dataframe(df, topcol, basecol=basecol, thickcol=thickcol, tol=tol)
        # print(df)
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


    @classmethod
    def from_numpy(self, arr, other=None, keys=None, component_map=None):
        """
        Implement a method to convert numpy (e.g., from GAN) to `BedSequence` instance.

        Use keys from `other`, or provide list of `keys`.
        Provide a `component_map` to group samples into `Bed`s.
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

        if self.order is 'depth':
            ax.invert_yaxis()

        ax.set_ylim([self.start.z, self.stop.z])

        if width_field:
            min_width = floor(self.min_field(width_field)-1)
            max_width = ceil(self.max_field(width_field)+1)
            ax.set_xlim([min_width, max_width])
            self.set_wentworth_ticks(ax, min_width, max_width, wentworth=wentworth)

        patches = []
        for bed in self:
            ax.add_patch(bed.as_patch(legend, width_field, depth_field,
                                      min_width, max_width, **kwargs))

        if self.order is 'depth':
            ax.invert_yaxis()

        if return_ax:
            return ax


    def set_wentworth_ticks(self, ax, min_psi, max_psi, wentworth='fine'):
        """
        Set the `xticks` for Wentworth grainsizes.
        """
        scale = wentworth_scale_coarse if wentworth == 'coarse' else wentworth_scale_fine

        scale_names, scale_psis = zip(*scale)

        minor_locs, minor_labels, major_locs = [], [], []

        #for i, (name, psi) in enumerate(scale):
        for i in range(len(scale)):

            psi = scale_psis[i] if i != (len(scale)-1) else max(10, max_psi)
            prev_psi = scale_psis[i-1] if i != 0 else min_psi
            next_psi = scale_psis[i+1] if i < (len(scale)-2) else max_psi

            if next_psi < min_psi:
                continue
            elif prev_psi >= max_psi:
                break

            minor_locs.append((prev_psi + psi) / 2.)
            minor_labels.append(scale_names[i])

            major_locs.append(psi)

        ax.set_xticks(minor_locs, minor=True)
        ax.set_xticklabels(minor_labels, minor=True)

        ax.set_xticks(major_locs)
        ax.set_xticklabels(['']*len(major_locs))

        ax.tick_params('y', labelsize=16)
        ax.tick_params('x', which='minor', labelsize=12, labelrotation=60)
        #ax.tick_params('y', which='major', ticksize=16)

        return ax
