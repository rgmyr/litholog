"""
Utility functions.
"""
import numpy as np


def string2array(s):
    """
    Parse csv array string to (float) array.
    """
    vals = []
    for snum in s.split(','):
        try:
            vals.append(float(snum))
        except ValueError:
            pass
    return np.array(vals)


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
        assert len(x) == n, f'`len({x})` != n'
        return x
    except TypeError:
        return np.repeat(x, n)
