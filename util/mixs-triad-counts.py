#!/usr/bin/env python
# coding: utf-8


import pandas as pds
import sqlite3
import click
from git_root import git_root


@click.command(context_settings=dict(help_option_names=["-h", "--help"]))
@click.option(
    "--database",
    "-db",
    help="the path to sqlite db file",
    default=git_root(git_root("target/harmonized_table.db"))
)
@click.option(
    "--output_path",
    "-out",
    help="the path to where the output is saved as a tsv",
    default=git_root(git_root("target/mixs-triad-counts.tsv"))
)
def main(database, output_path):
    ## connect to sqlite db
    cnx = sqlite3.connect(database)

    ## connect to db and load mixs triad columns
    sql = "select env_broad_scale, env_local_scale, env_medium from biosample"
    df = pds.read_sql(sql, cnx)
    # print(df.head()) # peek at data


    ## get value_counts of each triad and load into data frame
    series = df.astype(str).value_counts() # the astype(str) is needed to count NaNs
    # print(series.head()) # peek at data

    count_df = (
        pds.DataFrame(series, columns=['count'])
        .sort_values(by='count', ascending=False)
        .reset_index()
    )
    # print(count_df.head()) # peek at data

    ## save counts to file
    count_df.to_csv(output_path, sep='\t', index=False)

if __name__ == "__main__":
    main() # cli interface

