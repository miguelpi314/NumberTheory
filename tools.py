from lmfdb import db


# Download tools

def ec_growth_torsion(degree, limit=None):
    return db.ec_torsion_growth.search(query={'degree': int(degree)}, projection=2, limit=limit)
