"""
Define default `striplog.Decor`s when using grainsize as the width field.
Also specify default csv/DataFrame fields to map to `Bed` attributes/data.
"""
# Zane comments:
    # Added missing interval decor, but we also need to assign these a default grain size so that they plot. I would assign them a grain size of -4 Psi
    # added a comment in gs2litho - at the beginning of that comment, there is a f' - is that on purpose?
    # I didnt yet add missing_interval_decor to component part of gs2litho becasue I'm not sure how we should deal with the grain size of a missing interval...
import numpy as np
from striplog import Component, Decor, Legend

from graphiclog import wentworth


###+++++++++++++++++++++###
### Default viz objects ###
###+++++++++++++++++++++###
mud_decor = Decor({
    'component' : Component({'lithology' : 'mud'}),
    'colour' : '#ad8150', # 'xkcd:LightBrown',
    'hatch' : 'none'
})

sand_decor = Decor({
    'component' : Component({'lithology' : 'sand'}),
    'colour' : '#fffe7a', #'xkcd:LightYellow',
    'hatch' : '.'
})

gravel_decor = Decor({
    'component' : Component({'lithology' : 'gravel'}),
    'colour' : '#ff9408', #'xkcd:tangerine',
    'hatch' : 'o'
})

missing_decor = Decor({
    'component' : Component({'lithology' : 'missing'}),
    'colour' : '#ffffff', #'xkcd:white',
    'hatch' : 'x'
})

litholegend = Legend([mud_decor, sand_decor, gravel_decor, missing_decor])


###++++++++++++++++++++###
### Default csv fields ###
###++++++++++++++++++++###
DEFAULT_FIELDS = {
    'top' : 'tops',
    'base' : 'bases'
}


def gs2litho(gs, units='psi'):
    """
    Map grainsize value `gs` to `striplog.Component`.

    If `gs` is None or np.nan, maps to 'missing' Component.

    If `units` is 'mm' or 'phi', will convert to 'psi' first.

    Psi is log2(gs_mm), so medium sand is -1 to -2.
    See more at https://en.wikipedia.org/wiki/Grain_size#/media/File:Wentworth_scale.png
    """
    if gs is None or gs is np.nan:
        return missing_decor.component

    if units is 'mm':
        gs = wentworth.gs2psi(gs)
    elif units is 'phi':
        gs = wentworth.phi2psi(gs)
    elif gs < -11 or gs > 10:
        raise UserWarning(f'gs value of {gs} is suspect... is this in `psi` units?')

    if gs <= -4:
        return mud_decor.component
    elif gs <= 1:
        return sand_decor.component
    else:
        return gravel_decor.component


DEFAULT_COMPONENT_MAP = ('mean_gs_mm', lambda gs: gs2litho(gs, units='mm'))
