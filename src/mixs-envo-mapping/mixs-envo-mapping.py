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

sql_file = "/home/mam/harmonized_table.db"
expected_total_rows = 14000000
# envo_url = 'https://raw.githubusercontent.com/EnvironmentOntology/envo/master/envo.owl'
envo_json_url = 'http://purl.obolibrary.org/obo/envo.json'
onto_prefix = "ENVO"

cnx = sqlite3.connect(sql_file)

# # this count may be as slow as any subsequent query!
# # and SQLite doesn't seem to have a fast sample random rows function
# expected_total_rows = pds.read_sql("select count(1) from biosample", cnx)
# expected_total_rows = expected_total_rows.iloc[0][0]

def json_url_to_graph(onto_url):
    fp = tempfile.NamedTemporaryFile(suffix='.json')
    urllib.request.urlretrieve(onto_url, fp.name)
    ont = OntologyFactory().create(fp.name, ignore_cache=True)
    return(ont)

def node_ids_from_graph(graph):
    ont_nodes = graph.nodes()
    ont_nodes = [str(node) for node in ont_nodes]
    return ont_nodes

def scope_ids(unscoped, prefix):
    r = re.compile("^" + prefix + ":")
    scoped_list = list(filter(r.match, unscoped))
    return scoped_list

def discover_id_pattern(example_ids):
    extracted = rexpy.extract(example_ids)
    extracted = extracted[0]
    extracted = re.sub("^\^", "", extracted)
    extracted = re.sub("\$$", "", extracted)
    return extracted
    

def get_and_tabulate(colname, expected_total_rows = 1000, row_fraction = 1.0):
    keep_sql_num = expected_total_rows
    if row_fraction < 1.0:
        keep_sql_num = int(expected_total_rows * row_fraction)

    pre_query = datetime.now()
    print("Reading " + str(keep_sql_num) + " rows (" + str(row_fraction) + "), starting at")
    print(pre_query)

    #sql = "select env_broad_scale, env_local_scale, env_medium from biosample limit " + str(keep_sql_num)
    q = "select " + colname + " from biosample limit " + str(keep_sql_num)
    df = pds.read_sql(q, cnx)

    post_query = datetime.now()
    print("Finished reading at")
    print(post_query)

    print(post_query - pre_query)

    counts_series = df[colname].value_counts()
    counts_frame = counts_series.to_frame()
    counts_frame.reset_index(level=0, inplace=True)
    counts_frame.columns = ['string', 'count']
    return counts_frame


def decompose_extracted(tabulated_frame, pattern):
    concat_pattern = pattern
    compiled_pattern = re.compile(concat_pattern)
    with_flag = tabulated_frame['string'].str.contains(compiled_pattern)
    tabulated_frame['term_found'] = with_flag
    #
    for_capture = '(' + concat_pattern + ')'
    p = re.compile(for_capture)
    extracts = tabulated_frame['string'].str.extract(p)
    tabulated_frame['found_term'] = extracts
    for_replacement = '\[?' + concat_pattern + '\]?'
    remaining_string = broad_frame['string'].replace(to_replace = for_replacement, value = '', regex = True)
    residual_prefix = '^[A-Z]+:'
    if re.match(residual_prefix,pattern):
        print("matches")
        remaining_string = remaining_string.replace(to_replace = residual_prefix, value = '', regex = True)
    tabulated_frame['remaining_string'] = remaining_string
    return tabulated_frame

graph = json_url_to_graph(envo_json_url)
example_ids = node_ids_from_graph(graph)
example_ids = scope_ids(example_ids, onto_prefix)
pattern = discover_id_pattern(example_ids)

broad_frame = get_and_tabulate("env_broad_scale", expected_total_rows, row_fraction = 0.1)
broad_frame = decompose_extracted(broad_frame, pattern)

print(broad_frame)

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




