#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  1 10:08:31 2021

@author: MAM
"""

import pandas as pd
from datetime import datetime
import os

harmonized_values_eav_fp = '../target/harmonized-values-eav.tsv'
harmonized_table_fp      = '../target/harmonized_table.tsv'
chunk_size = 100000

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

chunks = [x for x in range(0, harmonized_values_eav.shape[0], chunk_size)]

# for i in range(0, len(chunks) - 1):
#     print(chunks[i], chunks[i + 1] - 1)

start_time = datetime.now()
# print(row_count)
print(start_time)
harmonized_table = pd.concat([harmonized_values_eav.iloc[chunks[i]:chunks[i + 1] - 1].pivot(index='id',
                                                                                            columns='attribute', values='value') for i in range(0, len(chunks) - 1)])
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)

start_time = datetime.now()
# print(row_count)
print(start_time)
harmonized_table.to_csv(harmonized_table_fp, sep='\t', index=False)
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)