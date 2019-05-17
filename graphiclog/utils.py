"""
Utility functions.
"""
import numpy as np


def strings2array(elems):
    """
    Convert iterable of numeric strings to (float) array.
    """
    vals = []
    for elem in elems:
        try:
            vals.append(float(elem))
        except ValueError:
            pass
    return np.array(vals)


def string2array_matlab(s):
    """
    Parse matlab-style array string (e.g., "1.0, 2.0, 3.0") to float array.
    """
    elems = s.split(',')
    return strings2array(elems)

def string2array_pandas(s):
    """
    Parse pandas-style array string (e.g, "[1.0 2.0 3.0]") to float array.
    """
    elems = s.strip('[]').split(' ')
    return strings2array(elems)


def safelen(x):
    """
    Return the length of an array or iterable, or 1 for literals.
    """
    if isinstance(x, (np.ndarray, np.generic)):
        _x = np.squeeze(x)
        _shape, _ndim = _x.shape, _x.ndim
        assert _ndim <= 1, 'Using `safelen` of array with ndim > 1 is not allowed'
        return _shape[0] if _shape else 1
    else:
        try:
            return len(x)
        except TypeError:
            return 1


def saferep(x, n):
    """
    Repeat `x` to array of length `n` if it's a literal, or check that `len(x) == n` if it's iterable.
    """
    try:
        if len(x) == 1:
            raise TypeError
        assert len(x) == n, f'`len({x})` != {n}'
        return x
    except TypeError:
        return np.repeat(x, n)
