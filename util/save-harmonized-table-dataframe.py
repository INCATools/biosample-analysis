import csv
import pandas as pds
import sqlite3 as sql

# load dataframe using basic read_csv; this requires a lot of memory
# df = pds.read_csv('../target/harmonized-table.tsv.gz', sep='\t', dtype=str, quoting=csv.QUOTE_NONE)
# len(df) # -> 14300584

# read harmonized-table by chunks
chunks = []
chunkSize = 10**6
for chunk in pds.read_csv('../target/harmonized-table.tsv', sep='\t', dtype=str, quoting=csv.QUOTE_NONE, chunksize=chunkSize):
	chunks.append(chunk)
	
# create sqlite db and write each chunk into db; trying save the all the data at once failed
con = sql.connect('../target/harmonized_table.db')	
for chunk in chunks:
	chunk.to_sql(name='biosample', con=con, if_exists='append', index=False)

# save dataframe as parquet file
df = pds.concat(chunks, ignore_index=True)
df.to_parquet('../target/harmonized-table.parquet.gzip', compression='gzip')

# test loading from sqlite
# con = sql.connect('../target/harmonized_table.db')
# sqlDf = pds.read_sql('select * from biosample limit 10', con) # test loading 10 records
# sqlDf = pds.read_sql('select * from biosample', con) # test loading all records; NB: this is VERY expensive operation

# test loading parquet
# parquetDf = pds.read_parquet('../target/harmonized-table.parquet.gzip')
# len(parquetDf) # -> 14300584
