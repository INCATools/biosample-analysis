import os
from numpy.core.arrayprint import set_printoptions
from pandas.core import indexing
from runner import runner
import pandas as pd

INPUT_DIRECTORY = 'data/input/'
NLP_INPUT_DIRECTORY = 'data/nlp/input/'
NLP_OUTPUT_DIRECTORY = 'data/nlp/output/'

def post_nlp(fn):
    # Post-process the NLP output
    #nlpCols = ['Study_BiosampleId', 'category', 'BeginTerm', 'EndTerm', 'TokenizedTerm', 'PreferredTerm', \
    #            'CURIE', 'NaN1', 'SentenceID', 'NaN2', 'UMLS_CUI']
    in_fn = fn.replace('input','output')
    df = pd.read_csv(in_fn, low_memory=False, sep='\t')
    #df = df.drop(['NaN1', 'SentenceID', 'NaN2', 'UMLS_CUI'], axis = 1)
    df = df.drop_duplicates()
    out_fn = in_fn.replace('Input','Output')
    df.to_csv(out_fn, sep='\t', index=False)
    os.remove(in_fn)


df_ncbi = pd.read_csv(os.path.join(INPUT_DIRECTORY,'biosampleDescriptionDF.tsv'), low_memory=False, sep='\t')
df_gold = pd.read_csv(os.path.join(INPUT_DIRECTORY,'biosamples-expanded.tsv'), low_memory=False, sep='\t')

# Column conctenation for NLP
df_ncbi['studyBiosampleId'] = df_ncbi['StudyId']+'_'+df_ncbi['BiosampleId']
df_ncbi['text'] = df_ncbi['Name'] + '. ' + df_ncbi['Title'] + '. ' + df_ncbi['Description']

df_gold['text'] = df_gold['name'] + '. ' + df_gold['name'] + '. ' + df_gold['community'] + '. ' + df_gold['habitat']

nlp_ncbi_df = df_ncbi[['studyBiosampleId', 'text']]
nlp_gold_df = df_gold[['id', 'text']]

nlp_ncbi_input = os.path.join(NLP_INPUT_DIRECTORY, 'nlpNCBIInput.tsv')
nlp_gold_input = os.path.join(NLP_INPUT_DIRECTORY, 'nlpGOLDInput.tsv')

nlp_ncbi_df.to_csv(nlp_ncbi_input, sep='\t', index=False)
nlp_gold_df.to_csv(nlp_gold_input, sep='\t', index=False)
# NER using OGER (via runNER)
runner.run_oger(settings='settings.ini',workers=5)

#Postprocess
post_nlp(nlp_ncbi_input)
post_nlp(nlp_gold_input)
