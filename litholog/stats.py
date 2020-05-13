# Stats for beds

import numpy as np

def mean_gs(Bed):
    """
    Find thickness-weighted mean of grain size for a bed
    """
    return np.average(Bed.data['grain_size_psi'], weights=Bed.data['depth_m'])
# Note - might be better to do this at the Sequence scale due to accessing data using "get_field"

def max_gs(Bed):
    """
    Find maximum grain size value for a bed
    """
    return np.amax(Bed.data['grain_size_psi'])
# Note - might be better to do this at the Sequence scale due to accessing data using "get_field"

def net_to_gross(BedSequence):
    """
    Find sand percentage (i.e., net-to-gross) of a Sequence
    """
    th = seq.get_field('th')
    maxgs = seq.get_field('max_gs_psi')
    sandth = th[maxgs>-4]
    mudth = th[maxgs<=-4]
    totalth = np.sum(seq.get_field('th')) # NEED TO UPDATE WITH MISSING LITHOLOGY!!
    # totalth=totalth minus missing th
    ntg=np.sum(sandth)/totalth
    return ntg

def amalgamation_ratio(BedSequence):
    """
    Find amalgamation ratio of a Sequence (see definition in this paper https://doi.org/10.1111/j.1365-3091.2008.00995.x)
    """
    1. dont count mud on mud contacts
    2. find sand on sand contacts
    3. divide sand-on-sand contacts by total number of contacts
    return ar

def lith_blocks(BedSequence):
    """
    Find uninterupted blocks of a lithology
    """
    1. find sand-on-sand contacts
    2. sum thickness of those beds

    return blocks
