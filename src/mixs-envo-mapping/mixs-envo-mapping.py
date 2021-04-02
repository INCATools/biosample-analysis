# -*- coding: utf-8 -*-

# import numpy as np
import pandas as pds
import sqlite3
from datetime import datetime
# import rdflib
import re
import tempfile
import urllib.request
from ontobio.ontol_factory import OntologyFactory
from tdda import rexpy
import click
from runner import runner
# import nltk
# import os

#prepare to use a SQLite connection as a global
cnx = None

def create_named_tempfile(extension):
    fp = tempfile.NamedTemporaryFile(suffix=extension, delete=False)
    return(fp)

def json_url_to_graph(onto_url, temploc):
    # fp = tempfile.NamedTemporaryFile(suffix='.json')
    urllib.request.urlretrieve(onto_url, temploc)
    ont = OntologyFactory().create(temploc, ignore_cache=True)
    return(ont)

def node_ids_from_graph(graph):
    ont_nodes = graph.nodes()
    ont_nodes = [str(node) for node in ont_nodes]
    return ont_nodes

def scope_ids(unscoped, prefix):
    r = re.compile("^" + prefix + ":")
    scoped_ids = list(filter(r.match, unscoped))
    return scoped_ids

def discover_id_pattern(example_ids):
    extracted = rexpy.extract(example_ids)
    extracted = extracted[0]
    extracted = re.sub("^\^", "", extracted)
    extracted = re.sub("\$$", "", extracted)
    return extracted
    
# removed row_fraction = 1.0
def get_and_tabulate(colname, dbrows):
    pre_query = datetime.now()
    print("Reading " + str(dbrows) + " rows, starting at")
    print(pre_query)
    print('\n')
    #sql = "select env_broad_scale, env_local_scale, env_medium from biosample limit " + str(keep_sql_num)
    # add table name to status mesage beflow. not getting passed yet
    # using global cnx instead
    q = "select " + colname + " from biosample limit " + str(dbrows)
    df = pds.read_sql(q, cnx)

    post_query = datetime.now()
    print("Finished reading at")
    print(post_query)
    print('\n')

    print("SQLite read duration:")
    print(post_query - pre_query)
    print('\n')

    counts_series = df[colname].value_counts()
    counts_frame = counts_series.to_frame()
    counts_frame.reset_index(level=0, inplace=True)
    counts_frame.columns = ['string', 'count']
    return counts_frame


def decompose_extracted(tabulated_frame, id_pattern):
    concat_pattern = id_pattern
    for_capture = '(' + concat_pattern + ')'
    p = re.compile(for_capture)
    extracts = tabulated_frame['string'].str.extract(p)
    tabulated_frame['found_term'] = extracts
    tabulated_frame['found_term'] = tabulated_frame['found_term'].fillna('')
    for_replacement = '\[?' + concat_pattern + '\]?'
    remaining_string = tabulated_frame['string'].replace(to_replace = for_replacement, value = '', regex = True)
    residual_prefix = '^[A-Z]+:'
    if re.match(residual_prefix,id_pattern):
        remaining_string = remaining_string.replace(to_replace = residual_prefix, value = '', regex = True)
    tabulated_frame['remaining_string'] = remaining_string
    return tabulated_frame

def onto_json_to_runner_tsv(filename):
    # print(filename)
    # runner_tsv_filename = filename + '.tsv'
    # print(runner_tsv_filename)
    runner.json2tsv(filename, filename)
    # return(runner_tsv_filename)
    return


# required and default proably incompatible/redundant
@click.command()
@click.option('--dbfile',
              default="target/harmonized_table.db",
              help='Path to SQLite requiring annotations.',
              required=True)
# OR get expected total rows and desired fraction
# does that make things earier for anybody?
@click.option('--dbrows',
              default=1000,
              help='Path to SQLite requiring annotations.',
              required=True)
@click.option('--ontourl',
              default='http://purl.obolibrary.org/obo/envo.json',
              help='URL of a JSON reference ontology.',
              required=True)
@click.option('--ontoprefix',
              default='ENVO',
              help='Prefix corresponding to JSON reference ontology.',
              required=True)
@click.option('--oger_ini_file',
              default='conf/mapping_settings.ini',
              help='An OGER ini settings file.',
              required=True)
def clickmain(dbfile, dbrows, ontourl, ontoprefix, oger_ini_file):
    global cnx
    
    cnx = sqlite3.connect(dbfile)
    
    # downoad json ontology file, build graph,
    # get name and close file
    ontology_dl_file = create_named_tempfile('.json')
    ontology_dl_file_name = ontology_dl_file.name
    graph = json_url_to_graph(ontourl, ontology_dl_file_name)
    ontology_dl_file.close()
    
    # ontology_dl_file_size =  os.path.getsize(ontology_dl_file_name)
    # print(ontology_dl_file_size)
    
    example_ids = node_ids_from_graph(graph)
    example_ids = scope_ids(example_ids, ontoprefix)
    id_pattern = discover_id_pattern(example_ids)
    
    # removed row_fraction = 0.1
    summarized_input = get_and_tabulate("env_broad_scale", dbrows)
    summarized_input = decompose_extracted(summarized_input, id_pattern)
    
    # N = 9
    # with open(runner_tsv_filename) as myfile:
    #     head = [next(myfile) for x in range(N)]
    #     print("\n".join(head))
    
    print(summarized_input)
    
    for_oger = pds.concat([summarized_input['remaining_string']], axis=1).reset_index()
    for_oger.columns = ['id', 'text']
    for_oger.to_csv('target/runner_files/data/input/for_oger.tsv', sep = '\t', index=False)
    
    onto_json_to_runner_tsv(ontology_dl_file_name)
    nodes_file = ontology_dl_file_name + "_nodes.tsv"
    termlist_file = 'target/runner_files/data/terms/runner_termlist.tsv'
    runner.prepare_termlist(nodes_file, termlist_file)
    
    runner.run_oger(settings=oger_ini_file)
    
clickmain()

# can run this in IDE to emulate what click would pass to the clickmain fn
if(False):
    dbfile = 'target/harmonized_table.db'
    ontourl = 'http://purl.obolibrary.org/obo/envo.json'
    ontoprefix = 'ENVO'
    dbrows = 30000000
    oger_ini_file = 'conf/mapping_settings.ini'

# ### what kind of IRIs do we expect from ENVO?
# deprecated in favor of the ontobio download and parse above
# envo_graph = rdflib.Graph()
# envo_graph.load(envo_url)

# envo_id_q = """
# select * 
# where 
# { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> }
# """

# envo_id_res = envo_graph.query(envo_id_q)

# envo_id_res_frame = pds.DataFrame(envo_id_res, columns=envo_id_res.vars)

# ids_from_envo = envo_id_res_frame.iloc[:,0]
# has_envo_base = ids_from_envo.str.contains('^http://purl.obolibrary.org/obo/ENVO_\d+$')
# envo_base_ids = ids_from_envo[has_envo_base]
# envo_id_lengths = envo_base_ids.str.len()
# envo_id_lengths_tab = envo_id_lengths.value_counts()
# print(envo_id_lengths_tab)
# ###

### patterns...
# string with ENVO id (sometimes enclosed in []), which we will assume to be legit? or check the label?
# just ENVO id - look up class label and add?
# just a string, which will require NER
# envo:string


###

# # this count may be as slow as any subsequent query!
# # and SQLite doesn't seem to have a fast sample random rows function
# dbrows = pds.read_sql("select count(1) from biosample", cnx)
# dbrows = dbrows.iloc[0][0]




