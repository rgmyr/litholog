"""
Define default `striplog.Decor`s when using grainsize as the width field.
Also define default csv/DataFrame fields to map to `Bed` attributes/data.
"""
from striplog import Component, Decor, Legend


###+++++++++++++++++++++###
### Default viz objects ###
###+++++++++++++++++++++###
shl_decor = Decor({
    'component' : Component({'lithology' : 'shale'}),
    'colour' : 'darkgray',
    'hatch' : '-'
})

snd_decor = Decor({
    'component' : Component({'lithology' : 'sand'}),
    'colour' : 'gold',
    'hatch' : '.'
})

grv_decor = Decor({
    'component' : Component({'lithology' : 'gravel'}),
    'colour' : 'darkorange',
    'hatch' : 'o'
})

litholegend = Legend([shl_decor, snd_decor, grv_decor])


###++++++++++++++++++++###
### Default csv fields ###
###++++++++++++++++++++###
DEFAULT_FIELDS = {
    'top' : 'tops'
    'base' : 'bases'
}

def 

DEFAULT_COMPONENT_MAP = {
    ''
}
