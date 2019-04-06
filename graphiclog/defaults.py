"""
Define default `striplog.Decor`s when using grainsize as the width field.
Also define default csv/DataFrame fields to map to `Bed` attributes/data.
"""
from striplog import Component, Decor, Legend

###++++++++++++++++++++###
### Default csv fields ###
###++++++++++++++++++++###
DEFAULT_FIELDS = {
    'top' : 'tops'
    'base' : 'bases'
}


###++++++++++++++++++++++++###
### Default viz properties ###
###++++++++++++++++++++++++###
lithofacies = [
    Component({'lithology' : 'shale'}),
    Component({'lithology' : 'sand'})
]

shl_decor = Decor({
    'component' : facies[0],
    'colour' : 'darkgray',
    'hatch' : '-'
})

snd_decor = Decor({
    'component' : facies[1],
    'colour' : 'gold',
    'hatch' : '.'
})

litholegend = Legend([shl_decor, snd_decor])
