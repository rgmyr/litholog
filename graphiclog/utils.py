"""
Utility functions.
"""

def cast2float(x):
    """
    Cast `x` to float. Raises ValueError if not castable.
    """
    pass


def string2array(x):
    """
    Parse string to (float) array.
    """
    pass


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
    Repeat `x` to array of length `n` if it's a literal, or check that `safelen(x) == n` iterable.
    """
    

    pass
