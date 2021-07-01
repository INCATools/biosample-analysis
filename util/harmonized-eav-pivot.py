#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  1 10:08:31 2021

@author: MAM
"""

import pandas as pd
from datetime import datetime
import os

row_frac = 0.65

harmonized_values_eav_fp = '../target/harmonized-values-eav.tsv'

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

hveav_rows = len(harmonized_values_eav.index)

row_count = round(hveav_rows * row_frac)
row_subset = harmonized_values_eav.head(row_count)

start_time = datetime.now()
print(row_count)
print(start_time)
harmonized_table = row_subset.pivot(
    index='id', columns='attribute', values='value')
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)

# 1645507
# 2021-07-01 10:28:23.313770
# 2021-07-01 10:28:25.718410
# 0:00:02.404640

# 4936522
# 2021-07-01 10:29:56.187996
# 2021-07-01 10:30:07.462798
# 0:00:11.274802

# 16455072
# 2021-07-01 10:30:30.261221
# 2021-07-01 10:32:05.181426
# 0:01:34.920205

row_frac = 1.0
hveav_rows = len(harmonized_values_eav.index)

row_count = round(hveav_rows * row_frac)
row_subset = harmonized_values_eav.head(row_count)
chunk_size = 50000
chunks = [x for x in range(0, row_subset.shape[0], chunk_size)]

for i in range(0, len(chunks) - 1):
    print(chunks[i], chunks[i + 1] - 1)

start_time = datetime.now()
print(row_count)
print(start_time)
harmonized_table = pd.concat([row_subset.iloc[chunks[i]:chunks[i + 1] - 1].pivot(index='id',
                                                                       columns='attribute', values='value') for i in range(0, len(chunks) - 1)])
end_time = datetime.now()
print(end_time)
time_diff = end_time - start_time
print(time_diff)
