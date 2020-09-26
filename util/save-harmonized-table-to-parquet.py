import sys
import csv
import pandas as pds

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

# save dataframe as parquet file
print('concatenating chunks')
df = pds.concat(chunks, ignore_index=True)
print('saving as parquet')
df.to_parquet(outputFile, compression='gzip')

# test loading parquet
# parquetDf = pds.read_parquet('../target/harmonized-table.parquet.gzip')
# len(parquetDf) # -> 14300584
