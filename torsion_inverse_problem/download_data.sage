from collections import defaultdict
import joblib
from lmfdb import db

query = [('ec_torsion_growth', {'degree' : int(2)})]
torsion_growth_with_local_data = db.ec_torsion_growth.join_search(query=query,
                                        projection=["lmfdb_label", "torsion", "degree", "field", "conductor", ("ec_curvedata", "torsion_structure"),("ec_curvedata", "absD"),("ec_localdata", "reduction_type"),("ec_localdata","prime"),("ec_localdata","kodaira_symbol")],
                                        join=[("ec_torsion_growth", "lmfdb_label", "ec_curvedata","lmfdb_label"), ("ec_torsion_growth", "lmfdb_label", "ec_localdata","lmfdb_label")])

torsion_growth_with_local_data = list(torsion_growth_with_local_data)

x = polygen(ZZ, 'x')

for elliptic_curve in torsion_growth_with_local_data:
    elliptic_curve['torsion_before'] = elliptic_curve[('ec_curvedata', 'torsion_structure')]
    elliptic_curve['torsion_after'] = elliptic_curve['torsion']
    elliptic_curve['curve_discriminant'] = elliptic_curve[('ec_curvedata', 'absD')]
    elliptic_curve['prime'] = elliptic_curve[('ec_localdata', 'prime')]
    elliptic_curve['kodaira_symbol'] = elliptic_curve[('ec_localdata', 'kodaira_symbol')]
    elliptic_curve['reduction_type'] = elliptic_curve[('ec_localdata', 'reduction_type')]

    del elliptic_curve['torsion']
    del elliptic_curve[('ec_curvedata', 'torsion_structure')]
    del elliptic_curve[('ec_curvedata', 'absD')]
    del elliptic_curve[('ec_localdata', 'prime')]
    del elliptic_curve[('ec_localdata', 'kodaira_symbol')]
    del elliptic_curve[('ec_localdata', 'reduction_type')]

    f = elliptic_curve['field']
    K. < a > = NumberField(f[0] * x ^ 2 + f[1] * x + f[2])
    elliptic_curve['disc_abs'] = K.absolute_discriminant()

# Diccionario para agrupar por lmfdb_label, torsion_before y torsion_after
grouped_data = defaultdict(
    lambda: {'lmfdb_label': '', 'degree': None, 'field': [], 'conductor': None, 'torsion_before': [],
             'torsion_after': [], 'curve_discriminant': None, 'disc_abs': None, 'prime_red_kodaira': []})

# Agrupamos los datos
for entry in torsion_growth_with_local_data:
    key = (entry['lmfdb_label'], tuple(entry['torsion_before']), tuple(entry['torsion_after']))
    grouped_data[key]['lmfdb_label'] = entry['lmfdb_label']
    grouped_data[key]['degree'] = entry['degree']
    grouped_data[key]['field'] = entry['field']
    grouped_data[key]['conductor'] = entry['conductor']
    grouped_data[key]['torsion_before'] = entry['torsion_before']
    grouped_data[key]['torsion_after'] = entry['torsion_after']
    grouped_data[key]['curve_discriminant'] = entry['curve_discriminant']
    grouped_data[key]['disc_abs'] = entry['disc_abs']

    # Añadimos el triple (prime, kodaira_symbol, reduction_type)
    grouped_data[key]['prime_red_kodaira'].append((entry['prime'], entry['reduction_type'], entry['kodaira_symbol']))

# Convertimos el resultado a una lista de diccionarios
torsion_growth_with_local_data = list(grouped_data.values())


joblib.dump(torsion_growth_with_local_data, 'torsion_growth_with_local_data.pkl')
