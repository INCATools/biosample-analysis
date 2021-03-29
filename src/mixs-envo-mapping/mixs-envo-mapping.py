# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
import pandas as pds
import sqlite3
from datetime import datetime

sql_file = "/home/mam/harmonized_table.db"

expected_total_rows = 14000000
keep_sql_frac = 0.1
keep_sql_num = int(expected_total_rows * keep_sql_frac)

cnx = sqlite3.connect(sql_file)

pre_query = datetime.now()
print("Reading ", keep_sql_num, " rows (", keep_sql_frac ,"), starting at")
print(pre_query)

sql = "select env_broad_scale, env_local_scale, env_medium from biosample limit " + str(keep_sql_num)
# print(sql)
df = pds.read_sql(sql, cnx)

post_query = datetime.now()
print("Finished reading at")
print(post_query)

print(post_query - pre_query)

broad_counts = df['env_broad_scale'].value_counts()

