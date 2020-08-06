"""
Sequence stats + related.
"""
from abc import ABC

import numpy as np


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

        not_missing = lambda bed: bed.lithology != 'missing'
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
            elif upper.lithology == 'missing' or lower.lithology == 'missing':
                continue
            total_contacts += 1

        try:
            return sand_contacts / total_contacts
        except ZeroDivisionError:
            return -1.


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


    @staticmethod
    def _hurst_K(x, take_log=True, safe=True):
        """
        Computes Hurst K ``log(R(n)/S(n)) / log(x.size / 2)`` for 1D array ``x``
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
