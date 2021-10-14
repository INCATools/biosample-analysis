#!/usr/bin/env python
# coding: utf-8

import pandas as pds
from git_root import git_root
import click

# set defaults to make click options shorter
DEFAULT_INPUT = git_root("downloads/nmdc-gold-path-ner/runner/runNER_Output.tsv")
DEFAULT_OUTPUT = git_root("target/nmdc-biosample-one-hot.tsv")


@click.command(context_settings=dict(help_option_names=["-h", "--help"]))
@click.option("--input", "-i", default=DEFAULT_INPUT)
@click.option("--output", "-o", default=DEFAULT_OUTPUT)
@click.option("--delimiter", "-d", default="\t")
@click.option("--use-entity-id", default=False)
def main(input, output, delimiter, use_entity_id):
    # read runNER output
    df_ner = pds.read_csv(input, sep=delimiter)

    # get a unique lists of the gold and match entity ids
    gold_ids = list(df_ner["DOCUMENT ID"].unique())
    if use_entity_id:
        matched_ids = list(df_ner["ENTITY ID"].unique())
    else:
        matched_ids = list(df_ner["PREFERRED FORM"].unique())

    # create one-hot encoded data frame with gold ids as the index but with empty features
    onehot_df = pds.DataFrame(columns=matched_ids, index=gold_ids).rename_axis(
        "gold_id"
    )
    onehot_df.fillna(0, inplace=True)  # set all features to 0

    # group NER output by the document ids
    if use_entity_id:
        grouped = df_ner.groupby("DOCUMENT ID")["ENTITY ID"]
    else:
        grouped = df_ner.groupby("DOCUMENT ID")["PREFERRED FORM"]

    # for each group of gold ids assign "1" to one-hot encoded column
    # if the value of the group is present
    for idx, series in grouped:
        for col in onehot_df.columns:
            if col in series.values:
                onehot_df.loc[idx, col] = 1

    # save output (note: make sure index is true to save them to file)
    onehot_df.to_csv(output, sep=delimiter, index=True)


if __name__ == "__main__":
    main()
