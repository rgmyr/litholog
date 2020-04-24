# Stats for beds

import numpy as np

def mean_gs(Bed):
    """
    Find thickness-weighted mean of grain size for a bed
    """
    return np.average(gs,axis=thickness)

def max_gs(Bed):
    """
    Find maximum grain size value for a bed
    """
    return np.amax(gs)

def net_to_gross(BedSequence):
    """
    Find sand percentage (i.e., net-to-gross) of a Sequence
    """
    ntg=components.Sand.th()./components.total.th()
    return ntg

def amalgamation_ratio(BedSequence):
    """
    Find amalgamation ratio of a Sequence (see https://doi.org/10.1111/j.1365-3091.2008.00995.x)
    """
    1. dont count mud on mud contacts
    2. find sand on sand contacts
    3. divide by total number of contacts
    return ar

def lith_blocks(BedSequence):
    """
    Find uninterupted blocks of a lithology
    """

    return blocks----------------------
