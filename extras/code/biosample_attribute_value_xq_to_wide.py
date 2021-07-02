#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 09:50:14 2021

@author: MAM
"""

import os
import pandas as pd
import datetime

print(os.getcwd())

# print statements lag
# use log messages or print to std err instead?

biosample_attribute_value_long_file = "target/biosample_attribute_value_xq.tsv"


# one minute?
print(datetime.datetime.now())
print("reading " + biosample_attribute_value_long_file)
biosample_attribute_value_long = pd.read_csv(biosample_attribute_value_long_file, sep='\t')
print(datetime.datetime.now())

bsa_row_count = len(biosample_attribute_value_long.index)

keep_frac = 0.2
keep_num = bsa_row_count * keep_frac
print(keep_frac, keep_num)
biosample_attribute_value_long_partial = biosample_attribute_value_long.loc[0:keep_num,]

# #---- probably slow. should time this too
# # is this causing a out of memory condition? lower priority than doing the pivot
# print(datetime.datetime.now())
# print("counting duplicated sample/harmonized name pairs")
# duplicated_sample_harmonized_names = biosample_attribute_value_long_partial.groupby(
#     ['accession', 'harmonized_name']).size().reset_index().rename(
#     columns={0: 'count'})
# print(datetime.datetime.now())
# print("only keeping duplicates")
# duplicated_sample_harmonized_names = duplicated_sample_harmonized_names[duplicated_sample_harmonized_names['count'] > 1]
# print(datetime.datetime.now())
# print("sorting")
# duplicated_sample_harmonized_names.sort_values(['count', 'harmonized_name', 'accession'], ascending=[False, True, True])
# print(datetime.datetime.now())
# duplicated_sample_harmonized_names.to_csv("target/duplicated_sample_harmonized_names.csv", index=False, sep="\t")

#---- probably slow. should time this too
print(datetime.datetime.now())
print("casting long data to strings")
biosample_attribute_value_long_partial = biosample_attribute_value_long_partial.applymap(str)

print(datetime.datetime.now())
print("pivoting with | join of duplicate values")
biosample_attribute_value_wide = biosample_attribute_value_long_partial.pivot_table(index='accession',
                                                                            columns='harmonized_name',
                                                                            values='attribute_value',
                                                                            aggfunc='|'.join)
print(datetime.datetime.now())

# Traceback (most recent call last):
#   File "<input>", line 50, in <module>
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/frame.py", line 7031, in pivot_table
#     return pivot_table(
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/reshape/pivot.py", line 146, in pivot_table
#     table = agged.unstack(to_unstack)
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/frame.py", line 7352, in unstack
#     result = unstack(self, level, fill_value)
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/reshape/reshape.py", line 417, in unstack
#     return _unstack_frame(obj, level, fill_value=fill_value)
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/reshape/reshape.py", line 444, in _unstack_frame
#     return _Unstacker(
#   File "/Users/MAM/Documents/gitrepos/biosample-basex/venv/lib/python3.9/site-packages/pandas/core/reshape/reshape.py", line 116, in __init__
#     raise ValueError("Unstacked DataFrame is too big, causing int32 overflow")
# ValueError: Unstacked DataFrame is too big, causing int32 overflow

print(datetime.datetime.now())

biosample_attribute_value_wide.to_csv("target/biosample_attribute_value_wide.tsv", index=False, sep="\t")

