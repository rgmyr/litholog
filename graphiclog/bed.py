import operator
import numpy as np
import matplotlib as mpl
from scipy import interpolate

from striplog import Interval

from graphiclog import utils


class Bed(Interval):
    """
    Represents an individual bed or layer.

    Essentially a ``striplog.Interval`` with some additional restrictions and logic.

    Beds are required to have a ``top``, ``base``, and ``data`` (which can be an array or dict-like).
    """
    def __init__(self, top, base, data, keys=None, **kwargs):
        """
        Parameters
        ----------
        top : float
            Top depth or elevation of bed.
        base : float
            Base depth or elevation of bed.
        data : array or dict-like
            Object from which to populate ``Bed`` data. If an array, must be 1-D or 2-D.
            Supported dict-like types include ``dict`` subclasses, ``pd.Series`` and ``namedtuple`` instances.
        keys : list(str), optional
            If ``data`` is an array, ``keys`` can be a list of string keys corresponding to array columns.
            Columns with a single unique value are collapsed to that value, while multi-value columns are kept as arrays.
            If ``data`` is an array and ``keys`` is ``None``, whole array is added under ``'_values'`` key.
        **kwargs
            Any additional keyword args for ``striplog.Interval`` constructor. (``components``, etc.)
        """

        if hasattr(data, 'to_dict'):        # handle `pd.Series` (e.g., from `df.iterrows()`)
            data = data.to_dict()
        elif hasattr(data, '_asdict'):      # handle `namedtuple` (e.g., from `df.itertuples()`)
            data = data._asdict()

        # `data` must either be dict subclass or np.ndarray now
        if isinstance(data, dict):
            assert all(type(k) is str for k in data.keys()), 'Only string keys allowed for dict-like Bed `data`'
            self.data = data

        elif isinstance(data, (np.ndarray, np.generic)):
            data = np.expand_dims(data, 0) if data.ndim == 1 else data
            assert data.ndim == 2, 'Array Bed `data` cannot have more than 2 dimensions'

            if keys:
                assert len(keys) == data.shape[-1], 'Number of `keys` must match columns in array `data`'
            else:
                keys = ['_values']

            self.data = {k : None for k in keys}
            self.values = data

        else:
            raise TypeError(f'Bed `data` type must be array or dict-like, not {type(data)}')

        Interval.__init__(self, top, base=base, data=self.data, **kwargs)


    @property
    def values(self):
        if '_values' in self.data.keys():
            return self.data['_values']
        else:
            lens = [utils.safelen(v) for v in self.data.values()]
            assert len(set(lens)) <= 2, f'Lengths of `.data` values must be [1,N] only, found: {set(lens)} {self.data}'
            # TODO: double check that this is safe and works right
            return np.vstack([utils.saferep(v, max(lens)) for v in self.data.values()]).T

    @values.setter
    def values(self, new_values):
        assert new_values.ndim == 2, f'`values` can only be set with 2D array, not {new_values.ndim}D'
        if '_values' in self.data.keys():
            # only check shape if `values` already exist
            if self['_values']:
                assert new_values.shape[1] == self.nfeatures, '`values` shape must have `nfeatures` columns'
            self.data['_values'] = new_values
        else:
            assert new_values.shape[1] == len(self.data.keys()), 'Number of columns must match len(self.data.keys())'
            for i, k in enumerate(self.data.keys()):
                new_col = new_values[:, i]
                self.data[k] = new_col[0] if np.unique(new_col).size == 1 else new_col


    def get_values(self, exclude_keys=[]):
        """
        Getter for ``values`` that allows dropping ``exclude_keys`` (e.g., sample depths) from array
        """
        values = self.values
        if not exclude_keys:
            return values

        exclude_idxs = [i for i, k in enumerate(self.data.keys()) if k in exclude_keys]
        return np.delete(values, exclude_idxs, axis=1)


    @property
    def nsamples(self):
        """
        The number of sample rows in ``values``.
        """
        return self.values.shape[0]

    @property
    def nfeatures(self):
        """
        The number of columns in ``values``.
        """
        return self.values.shape[1]


    def __getitem__(self, key):
        """
        Make the Bed instance indexable by ``data`` key or ``values`` column index.
        TODO: support for slices?
        """
        if type(key) is int and '_values' in self.data.keys():
            return self.values[:, key]
        else:
            return self.data.get(key)


    def resample_data(self, depth_key, step, kind='linear'):
        """
        Resample data to approximately ``step``, but preserving at least top/base samples.

        Parameters
        ----------
        depth_key : str, int, or None
            Dict key or column index pointing to sample depths
        step : float
            Depth step at which to (approximately) resample data values
        kind : one of {'linear','slinear','quadratic','cubic',...}, optional
            Kind of interpolation to use, default='linear'. See ``scipy.intepolate.interp1d`` docs.
        """
        old_ds = self[depth_key]
        single_sample = True if utils.safelen(old_ds) == 1 else False

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

        fill_value = (old_xs[0,:], old_xs[-1,:]) if self.order is 'depth' else (old_xs[-1,:], old_xs[0,:])
        interp_fn = interpolate.interp1d(old_ds, old_xs, kind=kind, axis=0, bounds_error=False, fill_value=fill_value)

        self.values = np.insert(interp_fn(new_ds), depth_idx, new_ds, axis=1)


    def max_field(self, key):
        """
        Return the maximum value of ``data[key]``, or ``None`` if it doesn't exist.
        """
        try:
            return max(self[key])
        except TypeError:
            return self[key]


    def min_field(self, key):
        """
        Return the minimum value of ``data[key]``, or ``None`` if it doesn't exist.
        """
        try:
            return min(self[key])
        except TypeError:
            return self[key]


    def spans(self, d, eps=1e-3):
        """
        Determines if position ``d`` is within this ``Bed``.
        Overridden from ``striplog.Interval`` to accomodate small tolerance `epsilon`

        Parameters
        ----------
        d : float
            Position (depth or elevation) to evaluate.

        Returns
        -------
        in_bed : bool
            True if ``d`` is within the ``Bed``, False otherwise.
        """
        o = {'depth': operator.le, 'elevation': operator.ge}[self.order]
        adjusted_top = self.top.z - eps if self.order is 'depth' else self.top.z + eps
        adjusted_base = self.base.z + eps if self.order is 'depth' else self.base.z - eps
        return (o(d, adjusted_base) and o(adjusted_top, d))


    def compatible_with(self, other):
        """
        Check that ``self.data`` and ``other.data`` have compatible ``values`` shapes and matching ``data`` key order.

        NOTE: Should both have to be constructed from similar dtypes, or just have concatable `values`?
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
        Representation of the ``Bed`` as a ``matplotlib.patches`` object [``Polygon`` or ``Rectangle``].

        Parameters
        ----------
        legend : ``striplog.Legend``
            Legend to get a matching ``striplog.Decor`` from.
        width_field : str or int, optional
            ``data`` key or ``values`` column index to use as width field.
        depth_field : str or int, optional
            Data key or ``values`` column index to use as positions of ``width_field`` samples.
            If not provided and ``width_field`` values are iterable, created from ``np.linspace(top, base)``.
            Ignored if ``width_field`` is a scalar. Sizes must match if both fields return iterables.

        Returns
        -------
        patch : instance from ``matplotlib.patches``
        """
        decor = legend.get_decor(self.primary)

        ws = self[width_field]
        if ws is None:
            ws = decor.width or 1
        #ws = (ws - min_width) / (max_width - min_width)

        # if we don't have depths, assumed samples are evenly spaced b/t `top` and `base`
        ds = self[depth_field] if depth_field else np.linspace(self.top.z, self.base.z, num=utils.safelen(ws))
        #print(self.top.z, self.base.z, '\n', ws, ds)

        patch_kwargs = {
            'fc' : kwargs.get('fc') or decor.colour,
            'lw' : kwargs.get('lw', 1),
            'hatch' : decor.hatch,
            'ec' : kwargs.get('ec', 'k'),
            **kwargs
        }

        # if `ws` is iterable, then make and return a Polygon
        if hasattr(ws, '__iter__'):
            assert len(ws) == len(ds), f'Must have equal number of width and depth sample values {self.data}'

            if not all(self.spans(d) for d in ds):
                raise ValueError(f'Depth sample values {ds} must fall between Bed top {self.top.z} and base {self.base.z}')

            return self._as_polygon(np.array(ws), np.array(ds), min_width, **patch_kwargs)

        # if `ws` is scalar, then make and return a plain Rectangle
        else:
            return self._as_polygon(np.array([ws, ws]), np.array([self.top.z, self.base.z]), min_width, **patch_kwargs)


    def _as_polygon(self, ws, ds, min_width, **kwargs):
        """
        Return the instance as a multi-width Polygon with the RHS defined by ``ws`` and ``ds``.

        ``min_width`` should be a reference to the ``width_field`` value at the y-axis (LHS).
        """
        # make sure that `ws` and `ds` are sorted for drawing
        idxs = np.argsort(ds)[::-1]
        ws, ds = ws[idxs], ds[idxs]

        # extend sample points to `top` and `base` if necessary
        if ds[0] != self.top.z:
            ds = [self.top.z] + list(ds)
            ws = [ws[0]] + list(ws)
        if ds[-1] != self.base.z:
            ds = list(ds) + [self.base.z]
            ws = list(ws) + [ws[-1]]

        # add the two points along the y-axis
        ds = np.array([self.top.z] + list(ds) + [self.base.z])
        ws = np.array([min_width] + list(ws) + [min_width])

        return mpl.patches.Polygon(np.vstack((ws, ds)).T, closed=True, **kwargs)
