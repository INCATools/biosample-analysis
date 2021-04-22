#!/usr/bin/env python3

# -*- coding: utf-8 -*-

from datetime import datetime
from ontobio.ontol_factory import OntologyFactory
from runner import runner
from strsimpy.cosine import Cosine
from tdda import rexpy
from urllib.request import urlopen
from xml.etree import ElementTree 
import click
import numpy as np
import pandas as pds
import re
import sqlite3
import string
import tempfile
import urllib.request

# get official package information
# observed values will frequently not match
# see also Chris's tabulation
# or tabulate inline
# this code could be moved somewhere else

# see also target/distinct-env_package.tsv

def get_package_dictionary():
    bio_s_columns = ['Name', 'DisplayName', 'ShortName', 'EnvPackage', 'EnvPackageDisplay', 'NotAppropriateFor',
                    'Description', 'Example']
    bio_s_df = pds.DataFrame(columns=bio_s_columns)
    
    bio_s_xml = urlopen('https://www.ncbi.nlm.nih.gov/biosample/docs/packages/?format=xml')
    bio_s_root = ElementTree.parse(bio_s_xml).getroot()

    for node in bio_s_root:
        rowdict = {}
        for framecol in bio_s_columns:
            # print(framecol)
            temp = node.find(framecol).text
            temptext = ''
            if temp is not None:
                temptext = temp
            # print(temptext)
            rowdict[framecol] = temptext
        # print(rowdict)
        bio_s_df = bio_s_df.append(rowdict, ignore_index=True)
    # bio_s_df['EnvPackage_nohyph'] = bio_s_df['EnvPackage'].str.replace('-', ' ', regex=True)
    print(bio_s_df)
    bio_s_df.to_csv('target/package_dictionary.tsv', sep='\t', index=False)
    return


def normalize_package_counts():
    raw_package_counts = pds.read_csv('target/distinct-env_package.tsv', sep='\t', header=None)
    raw_package_counts.columns = ['count', 'string']
    raw_package_counts['normalized'] = raw_package_counts['string'].str.replace('MIGS/MIMS/MIMARKS\.', '', regex=True)
    regex = re.compile('[%s]' % re.escape(string.punctuation))
    raw_package_counts['normalized'] = raw_package_counts['normalized'].str.replace(regex, ' ', regex=True)
    raw_package_counts['normalized'] = raw_package_counts['normalized'].str.lower()
    raw_package_counts['normalized'] = raw_package_counts['normalized'].str.strip()

    raw_package_counts['normalized'] = raw_package_counts['normalized'].str.replace('MIGS/MIMS/MIMARKS\.', '',
                                                                                    regex=True)
    norm_package_count = raw_package_counts.groupby(['normalized'])['count'].agg('sum')
    norm_package_count = norm_package_count.to_frame()

    total = np.sum(raw_package_counts['count'].values)
    norm_package_count['fraction'] = norm_package_count['count'] / total
    return norm_package_count


###

# reassemble triad values based on provided string or preferred string
# todo: look up labels when only a term id is provided
# todo: any quick way to estimate number of rows in SQLite database to give progress indicator?
# todo think about quadrants: with/without mappable string * with/without ontology term ID
# define actions for all four cases
# especially id but no string... add label back in?

# todo maybe should save downloaded ontology file
#   with a meaningful name
#   in a sensible location
#   instead of using a tempfile

# todo parameterize string tidying in decompose_series

# todo modify process_column so that it can handle zero rows
#   AND OR zero synonym splits


# prepare to use a SQLite connection as a global
cnx = None


def padded_print(*printables):
    print('\n')
    for printable in printables:
        print(printable)
    print('\n')


def create_named_tempfile(extension):
    fp = tempfile.NamedTemporaryFile(suffix=extension, delete=False)
    return fp


def json_url_to_graph(onto_url, temploc):
    urllib.request.urlretrieve(onto_url, temploc)
    ont = OntologyFactory().create(temploc, ignore_cache=True)
    return ont


def node_ids_from_graph(graph):
    ont_nodes = graph.nodes()
    ont_nodes = [str(node) for node in ont_nodes]
    return ont_nodes


def scope_ids(unscoped, prefix):
    r = re.compile('^' + prefix + ':')
    scoped_ids = list(filter(r.match, unscoped))
    return scoped_ids


def discover_id_pattern(example_ids):
    extracted = rexpy.extract(example_ids)
    extracted = extracted[0]
    extracted = re.sub('^\^', '', extracted)
    extracted = re.sub('\$$', '', extracted)
    return extracted


def get_as_is(colname_arg, dbrows_arg):
    pre_query = datetime.now()

    padded_print('Trying to read ' + str(dbrows_arg) + ' rows, starting at', pre_query)

    # removed ', package, package_name'
    q = 'select id, ' + colname_arg + ', env_package from biosample limit ' + str(dbrows_arg)
    df = pds.read_sql(q, cnx)

    post_query = datetime.now()
    padded_print('Finished reading at', post_query)

    post_query = datetime.now()
    padded_print('SQLite read duration:', post_query - pre_query)

    post_query = datetime.now()
    padded_print('Rows read:', len(df.index))

    return df


def decompose_series(series_to_decompose, id_pattern):
    extracts = series_to_decompose.to_frame()
    extracts.columns = ['string']
    for_capture = '(' + id_pattern + ')'
    p = re.compile(for_capture)
    extracts['extract'] = extracts['string'].str.extract(p)
    extracts = extracts.fillna('')
    for_replacement = '\[?' + id_pattern + '\]?'
    extracts['remaining_string'] = extracts['string'].str.replace(for_replacement, '', regex=True)
    extracts['remaining_tidied'] = extracts['remaining_string'].str.lower()
    extracts['remaining_tidied'] = extracts['remaining_tidied'].str.strip()
    # replace trailing punct, digits and whitespace
    # may not want to replace those for gene names?
    regex = re.compile('[%s\d ]*$' % re.escape(string.punctuation))
    extracts['remaining_tidied'] = extracts['remaining_tidied'].str.replace(regex, '', regex=True)
    return extracts


def just_tabluate(series_to_tabulate):
    counts_series = series_to_tabulate.value_counts()
    counts_frame = counts_series.to_frame()
    counts_frame.reset_index(level=0, inplace=True)
    counts_frame.columns = ['string', 'count']
    return counts_frame


def onto_json_to_runner_tsv(filename):
    runner.json2tsv(filename, filename)
    return


def dl_onto_get_pattern(ontourl_arg, ontoprefix_arg):
    # download json ontology file, build graph,
    # get name and close file
    # probably shouldn't actually use a tempfile
    #   and support reuse of existing OGER termlist

    url_bits = ontourl_arg.split('/')
    ontology_dl_file_name = url_bits[len(url_bits) - 1]
    ontology_dl_file_name = 'target/' + ontology_dl_file_name

    # ontology_dl_file = create_named_tempfile('.json')
    # ontology_dl_file_name = ontology_dl_file.name

    graph = json_url_to_graph(ontourl_arg, ontology_dl_file_name)
    # ontology_dl_file.close()
    example_ids = node_ids_from_graph(graph)
    example_ids = scope_ids(example_ids, ontoprefix_arg)
    id_pattern = discover_id_pattern(example_ids)
    return [ontology_dl_file_name, id_pattern]


def onto_to_termlist(ontology_dl_file_name):
    onto_json_to_runner_tsv(ontology_dl_file_name)
    nodes_file = ontology_dl_file_name + '_nodes.tsv'
    termlist_file_name = 'target/runner_files/data/terms/runner_termlist.tsv'
    runner.prepare_termlist(nodes_file, termlist_file_name)
    return


def get_accepted_packages():
    package_metadata = pds.read_csv('target/package_dictionary.tsv', sep='\t')
    accepted_env_package = set(
        package_metadata['EnvPackage'][package_metadata['ShortName'] == 'MIMS Environmental/Metagenome'])
    accepted_env_package_display = set(
        package_metadata['EnvPackageDisplay'][package_metadata['ShortName'] == 'MIMS Environmental/Metagenome'])
    accepted_packages = list(accepted_env_package.union(accepted_env_package_display))
    accepted_packages = pds.DataFrame(accepted_packages)
    accepted_packages.columns = ['package_string']
    accepted_packages['normalized'] = accepted_packages['package_string'].str.replace('-', ' ')
    return accepted_packages


# where to apply this?
def normalize_packages(as_is_result):
    # as_is_result = df

    # misc environment ?
    # built environment

    accepted_packages = get_accepted_packages()

    as_is_result['normalized'] = as_is_result['env_package'].str.replace('MIGS/MIMS/MIMARKS\.', '', regex=True)
    
    regex = re.compile('[%s]' % re.escape(string.punctuation))
    as_is_result['normalized'] = as_is_result['normalized'].str.replace(regex, ' ', regex=True)
    
    as_is_result['normalized'] = as_is_result['normalized'].str.lower()
    as_is_result['normalized'] = as_is_result['normalized'].str.strip()
    # as_is_result['normalized'] = as_is_result['normalized'].str.replace('MIGS/MIMS/MIMARKS\.', '', regex=True)
    
    as_is_result['normalized'] = as_is_result['normalized'].str.replace(' environment', '', regex=True)
    as_is_result = as_is_result[as_is_result['normalized'].isin(accepted_packages['normalized'])]
    return as_is_result


def process_column(db_column_arg, dbrows_arg, id_pattern, min_string_count_arg, oger_ini_file_arg, max_cosine_dist_arg):
    padded_print(db_column_arg)
    as_is_result = get_as_is(db_column_arg, dbrows_arg)

    as_is_result = normalize_packages(as_is_result)

    series_decomposition = decompose_series(as_is_result[db_column_arg], id_pattern)
    result_decomposition_concat = pds.concat([as_is_result, series_decomposition], axis=1)
    result_decomposition_concat['extract_len'] = result_decomposition_concat['extract'].str.len()
    result_decomposition_concat['remaining_len'] = result_decomposition_concat['remaining_tidied'].str.len()
    just_tabulation = just_tabluate(result_decomposition_concat.remaining_tidied)

    # discard empty strings
    for_oger = just_tabulation[just_tabulation.string.str.len() > 0]
    for_oger = for_oger[for_oger['count'] >= min_string_count_arg]

    for_oger = pds.concat([for_oger['string']], axis=1).reset_index()
    for_oger.columns = ['id', 'text']
    for_oger.to_csv('target/runner_files/data/input/for_oger.tsv', sep='\t', index=False)

    runner.run_oger(settings=oger_ini_file_arg)

    runner_results = pds.read_csv('target/runner_files/data/output/runNER_Output.tsv', sep='\t')

    # tease out synonyms
    split_for_syn = runner_results['ENTITY ID'].str.split('_', n=1, expand=True)
    print('\n')
    print('Synonym split results:')
    print(split_for_syn)
    print('\n')

    # splitting oger identified IDs on _, to separate out the synonym flag
    # assuming there are mappings against synonyms
    # starts acting funny here if there isn't at least one rwo with two cols
    # may require 10000000 rows with X vs Y
    # SQLite read takes ~ 30 seconds on ZZZ hardware

    is_syn = split_for_syn.iloc[:, 1] == 'SYNONYM'
    runner_results['is_syn'] = is_syn
    split_for_base = split_for_syn.loc[:, 0].str.split(':', n=1, expand=True)
    runner_results['match_prefix'] = split_for_base.loc[:, 0]

    cosine_obj = Cosine(1)

    runner_results['cosine'] = runner_results.apply(
        lambda row: cosine_obj.distance(row['SENTENCE'], row['MATCHED TERM']), axis=1)

    lowest_cosine_per_doc = runner_results.groupby('DOCUMENT ID')['cosine'].min()
    lowest_cosine_per_doc = lowest_cosine_per_doc.to_frame()

    best_runner_results = runner_results.merge(lowest_cosine_per_doc, how='inner', on=['DOCUMENT ID', 'cosine'])

    # best_runner_results.hist(column='cosine', bins = 99)

    best_over_threshold = best_runner_results[best_runner_results.cosine == max_cosine_dist_arg]

    doc_duplicity = best_over_threshold['DOCUMENT ID'].value_counts()
    single_match_doc_ids = doc_duplicity.index[doc_duplicity == 1].tolist()

    # done
    single_matchers = best_over_threshold.loc[best_over_threshold['DOCUMENT ID'].isin(single_match_doc_ids)]
    # look for docs with multiple matches but only one match against a preferred label
    multi_matchers = best_over_threshold.loc[~best_over_threshold['DOCUMENT ID'].isin(single_match_doc_ids)]

    matched_preferred = multi_matchers.loc[~multi_matchers.is_syn]
    matched_syn = multi_matchers.loc[multi_matchers.is_syn]
    # don't bother keeping if syn matches if a preferred match was available
    matched_syn = matched_syn[~matched_syn['DOCUMENT ID'].isin(matched_preferred['DOCUMENT ID'])]
    mp_duplicity = matched_preferred['DOCUMENT ID'].value_counts()
    single_mps = mp_duplicity.index[mp_duplicity == 1].tolist()
    # done
    single_prefereds = matched_preferred.loc[matched_preferred['DOCUMENT ID'].isin(single_mps)]
    done = pds.concat([single_matchers, single_prefereds], axis=0)
    multi_prefereds = matched_preferred.loc[~matched_preferred['DOCUMENT ID'].isin(single_mps)]
    # mine matched_syn and or multi_prefereds any more?
    all_best_doc_ids = set(best_over_threshold['DOCUMENT ID'])
    done_best_doc_ids = set(done['DOCUMENT ID'])
    unaccounted = all_best_doc_ids.difference(done_best_doc_ids)

    matched_syn_ids = set(matched_syn['DOCUMENT ID'])
    multi_prefereds_ids = set(multi_prefereds['DOCUMENT ID'])
    pending_ids = matched_syn_ids.union(multi_prefereds_ids)
    still_unaccounted = unaccounted.difference(pending_ids)
    print('\n')
    print('Number of filtered IDs left unaccounted for:')
    print(still_unaccounted)
    print('\n')

    # could filter out the multi preferred mappers 
    #  whose prefix matches the prefix provided by the user
    #  getting to diminishing return

    # #  would still have to check for duplicates
    # multi_but_scoped = multi_prefereds[multi_prefereds['match_prefix'] == ontoprefix]

    # the doc ids in 'done' are not expected to match the indices in result_decomposition_concat
    # have to join on strings
    input_run_ner_merge = result_decomposition_concat.merge(done, how='outer', left_on='remaining_tidied',
                                                            right_on='SENTENCE')
    # these are the 'done' runNER result inner-merged back into sql results from the INSDC MIXS table

    # really need to merge unmappeds back in
    # overall_ids = 9
    return input_run_ner_merge


def assembly_prep(processed_result):
    # processed_result = medium_processed
    # trim first?
    # trim multiple internal whitespace?
    # unused remaining tidied already start/end trimmed but also cropped of trailing digits, punct, whitespace
    pre_assembly = processed_result[
        ['id', 'string', 'extract', 'remaining_string', 'remaining_tidied', 'extract_len', 'remaining_len',
         'MATCHED TERM', 'PREFERRED FORM', 'ENTITY ID']]
    print(pre_assembly['extract_len'].value_counts())
    pre_assembly['extract_present'] = pre_assembly['extract_len'] > 0

    pre_assembly['remaining_string'] = pre_assembly['remaining_string'].str.strip()
    pre_assembly['remaining_len'] = pre_assembly['remaining_string'].str.len()
    rlc_freq_top = pre_assembly['remaining_len'].value_counts()
    rlc_short_top = rlc_freq_top.sort_index(ascending=True)
    print(rlc_short_top)
    pre_assembly['remaining_present'] = pre_assembly['remaining_len'] > 0

    pre_assembly = pre_assembly.drop(columns=['extract_len', 'remaining_len'])

    print(pds.crosstab(pre_assembly['extract_present'], pre_assembly['remaining_present'], dropna=False))

    # only remaining_tidied is lowercased so far?
    # does oger work internally with lowercased strings?
    # might want to keep original case for reassembling (annotated strings)
    # could also compare against remaining_tidied
    # remember, if the max cosine is set to 0.0, all matches will be exact
    pre_assembly['exact_match'] = np.where(pre_assembly['remaining_string'] == pre_assembly['MATCHED TERM'], True,
                                           False)
    print(pre_assembly['exact_match'].value_counts())

    pre_assembly['preferred_match'] = np.where(pre_assembly['remaining_string'] == pre_assembly['PREFERRED FORM'], True,
                                               False)
    print(pre_assembly['preferred_match'].value_counts())

    split_for_syn = pre_assembly['ENTITY ID'].str.split('_', n=1, expand=True)
    split_for_syn.columns = ['term_id', 'flag']
    split_for_syn['flag_len'] = split_for_syn['flag'].str.len()
    flag_len_counts = split_for_syn['flag_len'].value_counts()
    print(flag_len_counts)
    split_for_syn['flagged'] = split_for_syn['flag_len'] > 0
    split_for_syn = split_for_syn.drop(columns=['flag_len'])
    split_for_syn['flag'] = split_for_syn['flag'].fillna('')

    pre_assembly = pds.concat([pre_assembly, split_for_syn], axis=1)

    pre_assembly['term_id_identity'] = pre_assembly['extract'] == pre_assembly['term_id']
    print(pre_assembly['term_id_identity'])
    return pre_assembly


# required and default probably incompatible/redundant
@click.command()
@click.option('--dbfile',
              default='target/harmonized_table.db',
              help="""Path to a MIXS-formatted INSDC SQLite database 
              that requires annotations from an ontology.""",
              required=True, show_default=True)
# removed '... specified with --ontoprefix'
@click.option('--dbcol',
              default='env_broad_scale',
              help="""One of env_broad_scale, env_local_scale or env_medium.
              The values from that column will be mapped to the reference ontology
              specified by --ontourl""",
              required=True, show_default=True)
@click.option('--dbrows',
              default=1000,
              help='Maximum nuber of rows retreived from SQLite database specified by --dbfile.',
              required=True, show_default=True)
#  Use 0 for entire database?
@click.option('--ontourl',
              default='http://purl.obolibrary.org/obo/envo.json',
              help='URL pointing to an OBO JSON formatted ontology.',
              required=True, show_default=True)
# removed '...corresponding to JSON reference ontology'
# this determines what anchor will be used for extracting ontology terms 
#   that are already present in the triad columns
#   it doesn't determine what OGER corpus is used for the mapping
#   that's in the OGER ini file
#   maybe I need to add functionality to edit that within this script
@click.option('--ontoprefix',
              default='ENVO',
              help="""Prefix for extracting term IDs that are already present
              in the database column specified with --dbcol""",
              required=True, show_default=True)
@click.option('--oger_ini_file',
              default='conf/mapping_settings.ini',
              help='An OGER ini settings file.',
              required=True, show_default=True)
@click.option('--min_string_count',
              default=2,
              help="""Strings that appear less frequently, after tidying, 
              will not be submitted for annotation.""",
              required=True, show_default=True)
@click.option('--max_cosine_dist',
              default=0.0,
              help="""Mappings with a cosine string distance greater than this
              will be discarded in a first pass filter.""",
              required=True, show_default=True)
def clickmain(dbfile_arg, dbcol_arg, dbrows_arg, ontourl_arg, ontoprefix_arg, oger_ini_file_arg, min_string_count_arg,
              max_cosine_dist_arg):
    global cnx

    cnx = sqlite3.connect(dbfile_arg)

    cursor = cnx.execute('select * from biosample limit 3')
    # print(cursor.description)
    colnames = cursor.description
    sorted_rows = []
    for row in colnames:
        sorted_rows.append(row[0])
    sorted_rows.sort()
    print(sorted_rows)

    q = 'select count(*) from biosample'
    something = pds.read_sql(q, cnx)
    padded_print(something)

    pattern_prefix = dl_onto_get_pattern(ontourl_arg, ontoprefix_arg)
    ontology_dl_file_name = pattern_prefix[0]
    id_pattern = pattern_prefix[1]
    onto_to_termlist(ontology_dl_file_name)

    # need to capture output
    broad_processed = process_column('env_broad_scale', dbrows_arg, id_pattern, min_string_count_arg, oger_ini_file_arg,
                                     max_cosine_dist_arg)
    broad_pre_assembly = assembly_prep(broad_processed)
    print(broad_pre_assembly)

    # local_processed = process_column('env_local_scale', dbrows, id_pattern, min_string_count, oger_ini_file,
    # max_cosine_dist) print(local_processed)

    # medium_processed = process_column('env_medium', dbrows, id_pattern, min_string_count, oger_ini_file,
    # max_cosine_dist) print(medium_processed)

    # # should be able to tell which packages were enriched # just report for now package_combo_counts =
    # broad_processed.groupby(['env_package','package','package_name']).size().reset_index().rename(columns={
    # 0:'count'}) print(package_combo_counts)

    # medium_pre_assembly = assembly_prep(medium_processed)
    
@click.command()
def gpd_wrapper():
    get_package_dictionary()
    
@click.group(help="Methods for mapping semantic terms (eg from ENVO) to the mixs triad fields from BioSample. Can filter records based on MIXS checklist and guess target ontologies from MIXS package.")
def cli():
    pass

cli.add_command(gpd_wrapper)


if __name__ == '__main__':
    cli()

# can run this in IDE to emulate what click would pass to the clickmain fn
if False:
    dbfile_arg = 'target/harmonized_table.db'
    db_column = dbcol = colname = 'env_broad_scale'
    ontourl_arg = 'http://purl.obolibrary.org/obo/envo.json'
    ontoprefix_arg = 'ENVO'
    dbrows_arg = 20000000
    oger_ini_file_arg = 'conf/mapping_settings.ini'
    min_string_count_arg = 2
    max_cosine_dist_arg = 0.0

# ### what kind of IRIs do we expect from ENVO?
# deprecated in favor of the ontobio download and parse above
# envo_graph = rdflib.Graph()
# envo_graph.load(envo_url)

# envo_id_q = '''
# select * 
# where 
# { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> }
# '''

# envo_id_res = envo_graph.query(envo_id_q)

# envo_id_res_frame = pds.DataFrame(envo_id_res, columns=envo_id_res.vars)

# ids_from_envo = envo_id_res_frame.iloc[:,0]
# has_envo_base = ids_from_envo.str.contains('^http://purl.obolibrary.org/obo/ENVO_\d+$')
# envo_base_ids = ids_from_envo[has_envo_base]
# envo_id_lengths = envo_base_ids.str.len()
# envo_id_lengths_tab = envo_id_lengths.value_counts()
# print(envo_id_lengths_tab)

###

# # this count may be as slow as any subsequent query!
# # and SQLite doesn't seem to have a fast sample random rows function
# dbrows = pds.read_sql('select count(1) from biosample', cnx)
# dbrows = dbrows.iloc[0][0]


# ontology_dl_file_size =  os.path.getsize(ontology_dl_file_name)
# print(ontology_dl_file_size)

###
