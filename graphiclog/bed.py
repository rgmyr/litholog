
import numpy as np
import matplotlib as mpl

from striplog import Interval


class Bed(Interval):
    """
    Represents an individual 'bed'. Basically a striplog.Interval with additional restrictions and logic.
    Beds are required to have a top, base, and data.

    Parameters
    ----------
    top : float
        Top depth or elevation of bed.
    base : float
        Base depth or elevation of bed.
    data : array or dict-like
        Object from which to create `Bed` instance. If an array, must be 1- or 2-D.
        Supported dict-like types include dict subclasses, pd.Series and `namedtuple` subclasses.
    **kwargs
        Any additional keyword args for striplog.Interval constructor.
    """
    def __init__(self, top, base, data, **kwargs):

        if hasattr(data, 'to_dict'):        # handle pd.Series (e.g., from `df.iterrows()`)
            data = data.to_dict()
        elif hasattr(data, '_asdict'):      # handle `namedtuple` (e.g., from `df.itertuples()`)
            data = data._asdict()

        # `data` must either be ndarray or dict subclass now
        if isinstance(data, dict):
            assert all(type(k) is str for k in data.keys), 'Only string keys allowed for dict-like Bed `data`'
            self.data = data
        elif isinstance(data, (np.ndarray, np.generic)):
            data = np.expand_dims(data, 0) if data.ndim == 1 else data
            assert data.ndim == 2, 'Array `data` cannot have more then 2 dims'
            self.data = {'_values' : data}
        else:
            raise TypeError(f'Bed `data` type must be array or dict-like, not {type(data)}')

        Interval.__init__(self, top, base=base, data=data, **kwargs)


    @property
    def values(self):
        if '_values' in self.data.keys():
            return self.data['_values']
        else:
            max_len = max(safelen(v) for v in self.data.values())
            # TODO: double check that this is safe and works right
            return np.vstack([saferep(v, max_len) for v in self.data.values()]).T


    def __getitem__(self, key):
        """
        Make the Bed instance indexable by `data` key or `values` column index.
        TODO: support for slices?
        """
        if type(key) is int and '_values' in self.data.keys():
            return self.values[:, key]
        else:
            return self.data.get(key)


    def max_field(self, key):
        """
        Returns the maximum value of data[key], or None if it doesn't exist.
        """
        try:
            return max(self[field])
        except TypeError:
            return self[field]


    def min_field(self, key):
        """
        Returns the minimum value of data[key], or None if it doesn't exist.
        """
        try:
            return min(self[field])
        except TypeError:
            return self[field]


    def _compatible_with(self, other):
        """
        Check that `self.data` and `other.data` have compatible `values` shapes and matching `data` key order.

        ** Should both have to be constructed from similar dtypes, or just have concatable `values`?
        """
        keys_match = all([sk == ok for sk, ok in zip(self.data.keys(), other.data.keys())])
        shapes_match = self.values.shape[1] == other.values.shape[1]

        return keys_match and shapes_match


    def as_patch(self, legend,
                width_field=None,
                depth_field=None,
                min_width=0.,
                max_width=1.5, 
                **kwargs):
        """
        Return the instance as a `matplotlib.patches` object [Polygon or Rectangle].

        Parameters
        ----------
        legend : striplog.Legend
            Legend to get matching Decor from.
        width_field : str or int, optional
            Data key or values column index to use as width field
        depth_field : str or int, optional
            Data key or values column index to use as depths of `width_field` samples.
            If not provided and `width_field` values are iterable, created from np.linspace(top, base).
            Ignored if `width_field` is a scalar. Sizes must match if both return iterable/array.
        """
        decor = legend.get_decor(self.primary)

        ws = self[width_field] or decor.width or 1
        ws = (ws - min_width) / (max_width - min_width)
        ds = self[depth_field]

        patch_kwargs = {
            'fc' : kwargs.pop('fc') or decor.colour,
            'lw' : kwargs.pop('lw', 0),
            'hatch' : decor.hatch,
            'ec' : kwargs.pop('ec', 'k'),
            **kwargs
        }

        # if `ws` is iterable, then make and return a Polygon
        if hasattr(ws, '__iter__'):
            try:
                assert len(ws) == len(ds), 'Must have equal number of width and depth sample values'
                assert all(self.spans(d) for d in ds), 'Depth sample values must fall between Bed top and base'

            # if we don't have depths, assumed samples are evenly spaced b/t `top` and `base`
            except TypeError:
                ds = np.linspace(self.top.z, self.base.z, num=len(ws))

            return self._as_polygon(np.array(ws), np.array(ds), **patch_kwargs)

        # if `ws` is scalar, then make and return a plain Rectangle
        else:
            return self._as_rectangle(w, **patch_kwargs)



    def _as_rectangle(self, w, **kwargs):
        """
        Return the instance as a Rectangle of width `w`.
        """
        return mpl.patches.Rectangle((0, self.top.z), w, self.thickness, **kwargs)


    def _as_polygon(self, ws, ds, **kwargs):
        """
        Return the instance as a multi-width Polygon with the RHS defined by `ws` and `ds`.
        """
        # extend sample points to `top` and `base` if necessary
        if ds[0] != self.top.z:
            ds = [self.top.z] + list(ds)
            ws = [ws[0]] + list(ws)
        if ds[-1] != self.base.z:
            ds = list(ds) + [self.base.z]
            ws = list(ws) + [ws[-1]]

        # add the two points along the y-axis
        ds = np.array([self.top.z] + list(ds) + [self.base.z])
        ws = np.array([0.] + list(ws) + [0.])

        return mpl.patches.Polygon(np.vstack((ws, ds)).T, closed=True, **kwargs)
