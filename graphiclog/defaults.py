"""
Define default `striplog.Decor`s when using grainsize as the width field.
Also define default csv/DataFrame fields to map to `Bed` attributes/data.
"""
from striplog import Component, Decor, Legend


###+++++++++++++++++++++###
### Default viz objects ###
###+++++++++++++++++++++###
shale_decor = Decor({
    'component' : Component({'lithology' : 'shale'}),
    'colour' : 'darkgray',
    'hatch' : '-'
})

sand_decor = Decor({
    'component' : Component({'lithology' : 'sand'}),
    'colour' : 'gold',
    'hatch' : '.'
})

gravel_decor = Decor({
    'component' : Component({'lithology' : 'gravel'}),
    'colour' : 'darkorange',
    'hatch' : 'o'
})

litholegend = Legend([shale_decor, sand_decor, gravel_decor])


###++++++++++++++++++++###
### Default csv fields ###
###++++++++++++++++++++###
DEFAULT_FIELDS = {
    'top' : 'tops'
    'base' : 'bases'
}


def gs2litho(gs, units='psi'):
    """
    Map grainsize value `gs` to `striplog.Component`.
    If `units` is 'mm' or 'phi', will convert to 'psi' first.
    """
    if units is 'mm':
        gs = wentworth.gs2psi(gs)
    elif units is 'phi':
        gs = wentworth.phi2psi(gs)
    elif gs < -11 or gs > 10:
        raise UserWarning(f'gs value of {gs} is suspect... is this in `psi` units?')

    if gs <= -4:
        return shale_decor.component
    elif gs <= 1:
        return sand_decor.component
    else:
        return gravel_decor.component


DEFAULT_COMPONENT_MAP = ('grainsize_mm', lambda gs: gs2litho(gs, units='mm'))
