import os
from numpy.core.arrayprint import set_printoptions
from pandas.core import indexing
from runner import runner
import pandas as pd

INPUT_DIRECTORY = 'data/input/'
NLP_INPUT_DIRECTORY = 'data/nlp/input/'
NLP_OUTPUT_DIRECTORY = 'data/nlp/output/'

df = pd.read_csv(os.path.join(INPUT_DIRECTORY,'biosampleDescriptionDF.tsv'), low_memory=False, sep='\t')

# Column conctenation for NLP
df['studyBiosampleId'] = df['StudyId']+'_'+df['BiosampleId']
df['text'] = df['Name'] + ' ' + df['Title'] + ' ' + df['Description']
nlpDF = df[['studyBiosampleId', 'text']]
nlpDF.to_csv(os.path.join(NLP_INPUT_DIRECTORY, 'nlpInput.tsv'), sep='\t', index=False)

# NER using OGER (via runNER)
runner.run_oger(settings='settings.ini')

# Post-process the NLP output
nlpCols = ['Study_BiosampleId', 'category', 'BeginTerm', 'EndTerm', 'TokenizedTerm', 'PreferredTerm', \
            'CURIE', 'NaN1', 'SentenceID', 'NaN2', 'UMLS_CUI']
nlpDF = pd.read_csv(os.path.join(NLP_OUTPUT_DIRECTORY, 'nlpInput.tsv'), low_memory=False, sep='\t', names=nlpCols)
nlpDF = nlpDF.drop(['NaN1', 'SentenceID', 'NaN2', 'UMLS_CUI'], axis = 1)
nlpDF = nlpDF.drop_duplicates()

nlpDF.to_csv(os.path.join(NLP_OUTPUT_DIRECTORY, 'nlpOutput.tsv'), sep='\t', index=False)
