import sys
import csv
import pandas as pds
import sqlite3

inputFile = sys.argv[1]
outputFile = sys.argv[2]

# load dataframe using basic read_csv; this requires a lot of memory
# df = pds.read_csv('../target/harmonized-table.tsv.gz', sep='\t', dtype=str, quoting=csv.QUOTE_NONE)
# len(df) # -> 14300584

# read harmonized-table by chunks
print('reading chunks')
chunks = []
chunkSize = 10**6
for chunk in pds.read_csv(inputFile, sep='\t', dtype=str, quoting=csv.QUOTE_NONE, chunksize=chunkSize):
        chunks.append(chunk)
	
# create sqlite db and write each chunk into db; trying save the all the data at once failed
print('saving as sqlite3')
con = sqlite3.connect(outputFile)
for chunk in chunks:
	chunk.to_sql(name='biosample', con=con, if_exists='append', index=False)

# test loading from sqlite
# con = sqlite3.connect('../target/harmonized_table.db')
# sqlDf = pds.read_sql('select * from biosample limit 10', con) # test loading 10 records
# sqlDf = pds.read_sql('select * from biosample', con) # test loading all records; NB: this is VERY expensive operation
