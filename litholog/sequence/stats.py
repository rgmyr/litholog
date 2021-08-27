"""
Sequence stats + related.
"""
from abc import ABC

import numpy as np
from scipy.ndimage import gaussian_filter1d


def filter_nan_gaussian(arr, sigma, noise=None):
    """
    Gaussian convolution. (Allows intensity to leak into the NaN area.)

    If `noise` magnitude given, adds uniform noise.

    Implementation from stackoverflow answer:
        https://stackoverflow.com/a/36307291/7128154
    """
    gauss = arr.copy()
    gauss[np.isnan(gauss)] = 0
    gauss = gaussian_filter1d(gauss, sigma=sigma, mode='constant', cval=0)

    norm = np.ones(shape=arr.shape)
    norm[np.isnan(arr)] = 0
    norm = gaussian_filter1d(norm, sigma=sigma, mode='constant', cval=0)

    # avoid RuntimeWarning: invalid value encountered in true_divide
    norm = np.where(norm==0, 1, norm)
    gauss = gauss / norm

    # Add uniform noise, restricted positive
    if noise is not None:
        gauss += np.random.uniform(-noise, noise, size=gauss.size)
        gauss[gauss < 0.] = 0

    # Restore NaN
    gauss[np.isnan(arr)] = np.nan

    return gauss



class SequenceStatsMixin(ABC):
    """
    Defines the plot/viz interface for `BedSequence`.
    """
    @property
    def interfaces(self):
        """
        Get all pairs of adjacent Beds, ignoring any pairs with either Bed 'missing'
        """
        non_missing = lambda t: 'missing' not in [t[0].lithology, t[1].lithology]
        return filter(non_missing, zip(self[:-1], self[1:]))


    @property
    def net_to_gross(self):
        """
        Returns (total thickness of 'sand' Beds) / (total thickness of all Beds)
        """
        is_sand = lambda bed: bed.lithology == 'sand'
        sand_th = sum([bed.thickness for bed in filter(is_sand, self)])
        
        is_gravel = lambda bed: bed.lithology=='gravel'
        gravel_th = sum([bed.thickness for bed in filter(is_gravel, self)])


        not_missing = lambda bed: bed.lithology != 'missing'
        total_th = sum([bed.thickness for bed in filter(not_missing, self)])

        return (sand_th + gravel_th) / total_th


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
            elif upper.lithology == 'missing' or lower.lithology == 'missing':
                continue
            total_contacts += 1

        try:
            return sand_contacts / total_contacts
        except ZeroDivisionError:
            return -1.


    @staticmethod
    def _hurst_K(x, take_log=True, safe=True):
        """
        Computes Hurst K ``log(R(n)/S(n)) / log(x.size / 2)`` for 1D array ``x``

        Used below in public ``hurst_K`` and ``hurst_D`` methods.
        """
        x = np.array(x).squeeze()
        assert x.ndim == 1, 'Can only compute _rescaled_range on 1D series `x`'
        if safe and x.size < 20:
            raise UserWarning(f'Cannot use field of size {x.size} with ``safe=True``')

        if take_log:
            x = np.log10(x)

        y = x - x.mean()
        z = np.cumsum(y)

        Rn = z.max() - z.min()
        Sn = np.std(y)

        return np.log10(Rn / Sn) / np.log10(x.size / 2.)


    def hurst_K(self, field, lithology, safe=True):
        """
        Hurst K value for data from a sequence ``field``.

        If ``safe``, will only accept fields with at least 20 values.
        """
        values = self.get_field(field, lithology)

        return self._hurst_K(values, safe=safe)


    def hurst_D(self, field, lithology, take_log=True, safe=True, nsamples=1000, return_K=True):
        """
        Returns (D, p, K) if ``return_K``, else (D, p)
        where:
            D : Bootstrapped Hurst value from ``nsamples`` resamples
            p : p-value of ``D``
            K : Hurst K value with original values
        """
        values = self.get_field(field, lithology)
        K = self._hurst_K(values, take_log=take_log, safe=safe)

        ks = np.zeros(nsamples)
        for i in range(nsamples):
            _sample = np.random.choice(values, size=values.size, replace=True)
            ks[i] = self._hurst_K(_sample, take_log=take_log, safe=safe)

        D = (K - ks.mean()) / ks.std()
        p = np.sum(ks >= K) / nsamples

        return (D, p, K) if return_K else (D, p)


    def pseudo_gamma_simple(self,
                        gs_field='grain_size_mm',
                        depth_field='depth_m',
                        resolution=0.2,
                        gs_cutoff=0.0625,
                        gamma_range=(30, 180),
                        sigma=0.1,
                        noise=10.):
        """
        Compute a 'pseudo' gamma ray log by thresholding `gs_field` + Gaussian convolution.

        Parameters
        ----------
        gs_field: str
            Which field to use for grainsize
        depth_field: str
            Which field to use for depth
        resolution: float
            Scale at which to resample (in `depth_field` units)
        gs_cutoff: float
            Cutoff for `gs_field` thresholding. Values above/below get mapped to `gamma_range`.
        gamma_range: tuple or list
            (low, high) sample values for `gs_field` values (above, below) `gs_cuttoff`.
        sigma: float
            Width of Gaussian, in depth units.
        noise: float or None
            Magnitude of uniform noise to add, or None to add no noise.
        """
        ds, gs = self.get_field(depth_field), self.get_field(gs_field)

        # Make sure depth field is monotonic
        step_pos = np.diff(ds) > 0
        assert np.unique(step_pos).size == 1, '{depth_field} data is non-monotonic'

        # Must be increasing to use `np.interp`
        if not step_pos.all():
            ds, gs = ds[::-1], gs[::-1]

        # Resample `gs_field` at `resolution`
        nsamples = (np.abs(self.start.z-self.stop.z) // resolution) + 1
        sampled_ds = np.linspace(self.start.z, self.stop.z, num=int(nsamples), endpoint=True)
        sampled_gs = np.interp(sampled_ds, ds, gs)

        # Threshold `sampled_gs` to `gamma_range`
        nan_idxs = np.argwhere(np.isnan(sampled_gs))
        sampled_gs[nan_idxs] = gamma_range[1]
        pseudo_gr = np.where(sampled_gs < gs_cutoff, gamma_range[1], gamma_range[0])

        # Convolution
        pseudo_gr = gaussian_filter1d(pseudo_gr, sigma / resolution).astype('float64')

        if noise is not None:
            pseudo_gr += np.random.uniform(-noise, noise, size=pseudo_gr.size)
            pseudo_gr[pseudo_gr < 0.] = 0

        pseudo_gr[nan_idxs] = np.nan

        return sampled_ds, pseudo_gr
