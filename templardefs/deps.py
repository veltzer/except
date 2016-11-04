'''
dependencies for this project
'''

def populate(d):
    d.packs=[
        'doxygen',
        'libexplain51',
        'libexplain-dev',
        'libexplain-doc',
    ]

def getdeps():
    return [
        __file__, # myself
    ]
