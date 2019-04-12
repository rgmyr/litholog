"""
Utility functions for Wentworth/Krumbein logarithmic grainsize scale.
"""
import numpy as np
from math import floor, ceil

# Reference diameter (mm)
D0 = 1.0

# (name : upper PSI limit) ... upper limits taken as inclusive
wentworth_scale_fine = [
    ('colloid', -10),
    ('clay',    -8),
    ('vf_silt', -7),
    ('f_silt',  -6),
    ('m_silt',  -5),
    ('c_silt',  -4),
    ('vf_sand', -3),
    ('f_sand',  -2),
    ('m_sand',  -1),
    ('c_sand',   0),
    ('vc_sand',  1),
    ('vf_gravel',2),
    ('f_gravel', 3),
    ('m_gravel', 4),
    ('c_gravel', 5),
    ('vc_gravel',6),
    ('cobble',   8),
    ('boulder',  None)  # anything bigger than 8
]

wentworth_scale_coarse = [
    ('clay',  -8),
    ('silt',  -4),
    ('sand',   1),
    ('gravel', 6),
    ('cobble', 8),
    ('boulder', None)
]

#wentworth_names, wentworth_psis = zip(*wentworth_scale)


# PSI functions
def gs2psi(gs):
    return np.log2(gs / D0)

def psi2gs(psi):
    return D0 * 2**psi

def psi2phi(psi):
    return -psi


# PHI functions
def gs2phi(gs):
    return -np.log2(gs / D0)

def phi2gs(phi):
    return D0 * 2**(-phi)

def phi2psi(phi):
    return -phi


# Name funcs
def psi2name(psi, scale=wentworth_scale_fine):
    """Map single `psi` value to Wentworth bin name."""
    for name, upper_psi in scale[:-1]:
        if psi <= upper_psi:
            return name
    return scale[-1][0]

def phi2name(phi):
    return psi2name(-phi)

def gs2name(psi):
    return psi2name(gs2psi(gs))

"""
def psirange2names(min_psi, max_psi, return_tick_locs=False):
    min_idx = wentworth_names.index(psi2name(min_psi))
    max_idx = wentworth_names.index(psi2name(max_psi))
    max_idx = min(max_idx, len(wentworth_names)-2)

    names = wentworth_names[min_idx:max_idx+1]

    return wentworth_names[min_idx:max_idx+1]
"""

class WentworthAxis():
    """
    Manage the transformation of grainsize psi values to Striplog x-axis, and locs of corresponding ticks.
    """
    def __init__(self, gs_psi, scale='fine', min_bin_name=None, max_bin_name=None):

        self.scale = wentworth_scale_coarse if scale == 'coarse' else wentworth_scale_fine

        # change this... index won't work like that
        self.lower_psi = self.scale.index(min_bin_name) if min_bin_name else floor(min(gs_psi))
        self.upper_psi = self.scale.index(max_bin_name) if max_bin_name else ceil(max(gs_psi))


    def transform(self, gs_psi):
        """
        Map `psi` values to appropriate x-coords
        """
        pass

    def prepare_ax(self, ax):
        """
        Set x_lim and add gs ticks to axis.
        """
        ax.set_xlim([0.0, self.upper_psi - self.lower_psi])





if __name__ == '__main__':
    #psi = [x for _, x in wentworth_scale[:-1]] + [9]
    #for x in psi:
    #    print(x, psi2phi(x), psi2name(x), psi2gs(x))
    pass
