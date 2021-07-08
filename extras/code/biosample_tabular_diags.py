#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 09:50:14 2021

@author: MAM
"""

import pandas as pd

# several of these tasks could probably be performed with adequately sophisticated xqueries


biosample_tabular_file = "target/biosample_tabular.tsv"
mismatch_file = 'target/id_mismatches.tsv'

print("reading " + biosample_tabular_file)
biosample_basex = pd.read_csv(biosample_tabular_file, sep='\t')

# runfile('/Users/MAM/untitled0.py', wdir='/Users/MAM')
# <ipython-input-1-dd489b0991e3>:1: DtypeWarning: Columns (6,7,8,9,10)
#   have mixed types.Specify dtype option on import or set low_memory=False.
#   runfile('/Users/MAM/untitled0.py', wdir='/Users/MAM')

print(biosample_basex.columns)

# Index(['accession', 'primary_id', 'org_tax_id', 'org_tax_name', 'package',
#        'package_disp_name', 'env_package_attrib', 'env_broad_scale',
#        'env_local_scale', 'env_medium', 'host_taxid'],
#       dtype='object')

#----

biosample_basex['id_match'] = biosample_basex['accession'] == \
    biosample_basex['primary_id']

print('counting accession/primary id matches')
id_match_counts = biosample_basex['id_match'].value_counts(dropna=False)

# there are some accession/primary id mismatches
print('dumping biosamples with mismatched accessions/primary ids to ' + mismatch_file)

id_mismatches = biosample_basex[~biosample_basex.id_match]
id_mismatches.to_csv(mismatch_file, sep='\t', index=False)

#----

# based on teh structure of the data
# and the way concatenation was applied in the query
# do any accession numbers appear on more than one row?
print("looking for accessions that appear on more than one row")
accession_usage = biosample_basex['accession'].value_counts(dropna=False)
aum = accession_usage.max()
if aum > 1:
    print("some accessions appear on more than one row")
else:
    print("no accessions appear on more than one row")

#----

# manually discovered sample with two "model"s
print("SAMN00001340 and some other biosamples have two 'model' values")
print("We concatenate them together with pipes")
print("Same thing for description paragraphs")
multiple_model_flag = biosample_basex.accession == 'SAMN00001340'
multiple_model_example = biosample_basex[multiple_model_flag]
print(multiple_model_example[['accession', 'model']])

#----

# there actually aren't that many biosamples WITH a host taxon
# how to report/export this?
print("how many of the biosamples lack a host taxon id?")
has_host_taxid = biosample_basex.host_taxid.isnull()
has_host_taxid_counts = has_host_taxid.value_counts(dropna=False)
print(has_host_taxid_counts)
