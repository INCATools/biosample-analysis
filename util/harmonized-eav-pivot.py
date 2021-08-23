#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  1 10:08:31 2021

@author: MAM
"""

import gc
import os
import sys
from datetime import datetime

import pandas as pd

# harmonized_values_eav_fp = 'target/harmonized-values-eav.tsv'
# harmonized_table_fp      = 'target/harmonized-table.tsv'
harmonized_values_eav_fp = sys.argv[1]
harmonized_table_fp = sys.argv[2]

print(harmonized_values_eav_fp)
print(harmonized_table_fp)

# chunk_size = 100000
desired_avg_chunk_size = 200000

cwd = os.getcwd()
print(cwd)

start_time = datetime.now()
print(start_time)
# 1 minute
harmonized_values_eav = pd.read_csv(harmonized_values_eav_fp, sep="\t")
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)

# replace chunking by position
# by chunking by id below
# chunks = [x for x in range(0, harmonized_values_eav.shape[0], chunk_size)]
#
# # for i in range(0, len(chunks) - 1):
# #     print(chunks[i], chunks[i + 1] - 1)
#
# start_time = datetime.now()
# # print(row_count)
# print(start_time)
# harmonized_table = pd.concat([harmonized_values_eav.iloc[chunks[i]:chunks[i + 1] - 1].pivot(index='id',
#                                                                                             columns='attribute',
#                                                                                             values='value') for i in
#                               range(0, len(chunks) - 1)])
# end_time = datetime.now()
# print(end_time)
# time_diff = end_time - start_time
# print(time_diff)

row_count = len(harmonized_values_eav.index)
desired_chunk_count = row_count/desired_avg_chunk_size
harmonized_values_eav['chunk'] = round(harmonized_values_eav.id / desired_avg_chunk_size )
harmonized_values_eav['chunk'] = harmonized_values_eav['chunk'].astype(int)
id_vc = harmonized_values_eav['chunk'].value_counts()
print(id_vc)
print(len(id_vc.index))

splits = list(harmonized_values_eav.groupby("chunk"))
del harmonized_values_eav
gc.collect()

# test_count = 10
# test_list = splits[0:(test_count-1)]
# pivots = [current_tuple[1].pivot(index='id', columns='attribute', values='value') for current_tuple in test_list]

pivots = [current_tuple[1].pivot(index='id', columns='attribute', values='value') for current_tuple in splits]
del splits
gc.collect()

catted = pd.concat(pivots)
del pivots
gc.collect()

# > 45 minutes just for writing?!
start_time = datetime.now()
print(start_time)
catted.to_csv(harmonized_table_fp, sep='\t', index=True)
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)

