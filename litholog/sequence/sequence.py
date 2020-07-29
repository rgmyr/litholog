"""
Notes:
    - Just need top depths/elevations.
"""
import numpy as np
from math import floor, ceil
import matplotlib.pyplot as plt

from striplog import Striplog

from litholog import Bed
from litholog import utils
from litholog.sequence import SequenceIOMixin, SequenceVizMixin, SequenceStatsMixin


class BedSequence(SequenceIOMixin, SequenceVizMixin, SequenceStatsMixin, Striplog):
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


    def motif(self, location, size):
        assert size % 2 == 1, 'Should only do odd sizes.'

        first = location - (size // 2)
        last = location + (size // 2)

        assert first > 0 and last < len(self), f'Motif at {location, size} incompatible with {len(self)}'

        beds = self[first:last+1]

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
        Return array, result of applying `fn` values to `field` keys.

        The funcs can return scalars or arrays, but all of the return values
        should be numpy-concatable. The concatenation
        """
        try:
            vals = [self.reduce_field(field, fn) for field, fn in field_fn_dict.items()]
        except Exception as e:
            print(f'Error reducing fields for: {self.metadata}')
            raise(e)

        try:
            return np.concatenate(vals)
        except ValueError as ve:
            print(f'Incompatible shapes: {[v.shape for v in vals]}')
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
