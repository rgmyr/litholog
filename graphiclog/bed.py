
import numpy as np
import matplotlib as mpl
from scipy import interpolate

from striplog import Interval

from graphiclog import utils


class Bed(Interval):
    """
    Represents an individual bed or layer.
    Basically a `striplog.Interval` with some additional restrictions and logic.
    Beds are required to have a `top`, `base`, and `data` (which can be an array or dict-like).

    Parameters
    ----------
    top : float
        Top depth or elevation of bed.
    base : float
        Base depth or elevation of bed.
    data : array or dict-like
        Object from which to create `Bed` instance. If an array, must be 1- or 2-D.
        Supported dict-like types include dict subclasses, pd.Series and `namedtuple` instances.
    **kwargs
        Any additional keyword args for striplog.Interval constructor. (Components, etc.)
    """
    def __init__(self, top, base, data, **kwargs):

        if hasattr(data, 'to_dict'):        # handle `pd.Series` (e.g., from `df.iterrows()`)
            data = data.to_dict()
        elif hasattr(data, '_asdict'):      # handle `namedtuple` (e.g., from `df.itertuples()`)
            data = data._asdict()

        # `data` must either be ndarray or dict subclass now
        if isinstance(data, dict):
            assert all(type(k) is str for k in data.keys()), 'Only string keys allowed for dict-like Bed `data`'
            self.data = data
        elif isinstance(data, (np.ndarray, np.generic)):
            data = np.expand_dims(data, 0) if data.ndim == 1 else data
            assert data.ndim == 2, 'Array Bed `data` cannot have more than 2 dimensions'
            self.data = {'_values' : data}
        else:
            raise TypeError(f'Bed `data` type must be array or dict-like, not {type(data)}')

        Interval.__init__(self, top, base=base, data=self.data, **kwargs)


    @property
    def values(self):
        if '_values' in self.data.keys():
            return self.data['_values']
        else:
            lens = [utils.safelen(v) for v in self.data.values()]
            assert len(set(lens)) <= 2, f'Lengths of `.data` values must be [1,N] only, found: {set(lens)}'
            # TODO: double check that this is safe and works right
            return np.vstack([utils.saferep(v, max(lens)) for v in self.data.values()]).T

    @values.setter
    def values(self, new_values):
        assert new_values.ndim == 2, f'`values` can only be set with 2D array, not {new_values.ndim}D'
        if '_values' in self.data.keys():
            assert new_values.shape[1] == self.nfeatures, '`values` shape must have `nfeatures` columns'
            self.data['_values'] = new_values
        else:
            assert new_values.shape[1] == len(self.data.keys()), 'Number of columns must match len(self.data.keys())'
            for i, k in enumerate(self.data.keys()):
                new_col = new_values[:, i]
                self.data[k] = new_col[0] if np.unique(new_col).size == 1 else new_col

    @property
    def nsamples(self):
        """
        The number of sample rows in `values`.
        """
        return self.values.shape[0]

    @property
    def nfeatures(self):
        """
        The number of feature columns in `values`.
        """
        return self.values.shape[1]


    def __getitem__(self, key):
        """
        Make the Bed instance indexable by `data` key or `values` column index.
        TODO: support for slices?
        """
        if type(key) is int and '_values' in self.data.keys():
            return self.values[:, key]
        else:
            return self.data.get(key)


    def resample_data(self, depth_key, step, kind='linear'):
        """
        Resample data to approximately `step`, but preserving at least top/base samples.

        Parameters
        ----------
        depth_key : str, int, or None
            Dict key or column index pointing to sample depths
        step : float
            Depth step at which to (approximately) resample data values
        kind : one of {'linear','slinear','quadratic','cubic',...}, optional
            Kind of interpolation to use, default='linear'. See `scipy.intepolate.interp1d` docs.
        """
        old_ds = self[depth_key]
        single_sample = True if utils.safelen(old_ds) == 1 else False

        # TODO: finish this
        new_ds = np.linspace(self.top.z, self.base.z, num=max(2, (abs(self.top.z-self.base.z) // step)))

        if type(depth_key) is str:
            try:
                depth_idx = list(self.data.keys()).index(depth_key)
            except IndexError:
                raise ValueError(f'`depth_key` {depth_key} not in keys {self.data.keys()}')
        elif type(depth_key) is int:
            assert depth_key < self.nfeatures, f'`depth_key` {depth_key} too large for values shape {self.values.shape}'
            depth_idx = depth_key
        else:
            raise ValueError(f'`depth_key` must be `str` or `int`, not {type(depth_key)}')

        old_xs = np.delete(self.values, depth_idx, axis=1)

        if single_sample:
            old_ds = np.array([self.top.z, self.base.z])
            old_xs = np.repeat(old_xs, 2, axis=0)

        interp_fn = interpolate.interp1d(old_ds, old_xs, kind=kind, axis=0, fill_value='extrapolate')

        self.values = np.insert(interp_fn(new_ds), depth_idx, new_ds, axis=1)


    def max_field(self, key):
        """
        Return the maximum value of data[key], or None if it doesn't exist.
        """
        try:
            return max(self[key])
        except TypeError:
            return self[key]


    def min_field(self, key):
        """
        Return the minimum value of data[key], or None if it doesn't exist.
        """
        try:
            return min(self[key])
        except TypeError:
            return self[key]


    def compatible_with(self, other):
        """
        Check that `self.data` and `other.data` have compatible `values` shapes and matching `data` key order.

        ** Should both have to be constructed from similar dtypes, or just have concatable `values`?
        """
        keys_match = all([sk == ok for sk, ok in zip(self.data.keys(), other.data.keys())])
        shapes_match = self.values.shape[1] == other.values.shape[1]

        return keys_match and shapes_match


    @classmethod
    def from_numpy(self, arr):
        """
        Implement a method to convert numpy (e.g., from GAN) to `Bed` instance.
        """
        pass


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
            Legend to get a matching Decor from.
        width_field : str or int, optional
            Data key or `.values` column index to use as width field.
        depth_field : str or int, optional
            Data key or `.values` column index to use as depths of `width_field` samples.
            If not provided and `width_field` values are iterable, create from np.linspace(top, base).
            Ignored if `width_field` is a scalar. Sizes must match if both fields return iterable/array.
        """
        decor = legend.get_decor(self.primary)

        ws = self[width_field] or decor.width or 1
        ws = (ws - min_width) / (max_width - min_width)

        # if we don't have depths, assumed samples are evenly spaced b/t `top` and `base`
        ds = self[depth_field] if depth_field else np.linspace(self.top.z, self.base.z, num=utils.safelen(ws))

        patch_kwargs = {
            'fc' : kwargs.pop('fc') or decor.colour,
            'lw' : kwargs.pop('lw', 0),
            'hatch' : decor.hatch,
            'ec' : kwargs.pop('ec', 'k'),
            **kwargs
        }

        # if `ws` is iterable, then make and return a Polygon
        if hasattr(ws, '__iter__'):
            assert len(ws) == len(ds), 'Must have equal number of width and depth sample values'
            assert all(self.spans(d) for d in ds), 'Depth sample values must fall between Bed top and base'

            return self._as_polygon(np.array(ws), np.array(ds), **patch_kwargs)

        # if `ws` is scalar, then make and return a plain Rectangle
        else:
            return self._as_rectangle(ws, **patch_kwargs)


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
