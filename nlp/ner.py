import os
from runner import runner
import pandas as pd
# To run this file: python -c 'import ner; ner.post_ner("data/nlp/input/INPUT_FILENAME")'


INPUT_DIRECTORY = '../downloads/nmdc-gold-path-ner/'#'data/input/'
NLP_INPUT_DIRECTORY = 'data/nlp/input/'
NLP_OUTPUT_DIRECTORY = 'data/nlp/output/'
INPUT_FILE = 'nmdc-biosample-table-for-ner-20201016.tsv'
NLP_INPUT_FILE = 'nlpInput.tsv'
NLP_OUTPUT_FILE = 'runNER_Output.tsv'

def post_ner(input=os.path.join(NLP_INPUT_DIRECTORY, 'nlpInput.tsv')):
    '''
    Post process the NER output.
    '''
    
    # Import the runNER output and narrow down on useful info
    runner_output = pd.read_csv(os.path.join(NLP_OUTPUT_DIRECTORY, NLP_OUTPUT_FILE), sep='\t' )
    runner_output = runner_output.drop(['START POSITION', 'END POSITION', 'ZONE','SENTENCE ID', 'ORIGIN', 'UMLS CUI', 'SENTENCE'], axis = 1)
    runner_output = runner_output.drop_duplicates()
    runner_output['CURIE_SYNONYM_REMOVED'] = runner_output['ENTITY ID'].str.strip('_SYNONYM').str.replace(':','_')
    
    # Import main and nlp input files
    main_input = pd.read_csv(INPUT_DIRECTORY+INPUT_FILE, sep='\t', low_memory=False, usecols=['GOLD_ID', 'BROAD_SCALE_LABEL', 'LOCAL_SCALE_LABEL', 'MEDIUM_LABEL', 'ENV_BROAD_SCALE', 'ENV_LOCAL_SCALE', 'ENV_MEDIUM'] )
    nlp_input = pd.read_csv(input, sep='\t', low_memory=False, index_col=None)
    input_output_join = main_input.merge(runner_output, left_on='GOLD_ID', right_on='DOCUMENT ID', how='left' )
    input_output_join = input_output_join.drop(['DOCUMENT ID', 'ENTITY ID'], axis=1)
    input_output_join.to_csv(NLP_OUTPUT_DIRECTORY+'inputOutputJoined.tsv', sep='\t', index=None)

    # Find matches
    input_output_join['env_broad_matched'] = input_output_join['CURIE_SYNONYM_REMOVED'] == input_output_join['ENV_BROAD_SCALE']
    input_output_join['env_local_matched'] = input_output_join['CURIE_SYNONYM_REMOVED'] == input_output_join['ENV_LOCAL_SCALE']
    input_output_join['env_medium_matched'] = input_output_join['CURIE_SYNONYM_REMOVED'] == input_output_join['ENV_MEDIUM']
    input_output_join['false_positives'] = (input_output_join.iloc[:,-3:]==False).all(True)
    
    # Group by all columns except the boolean ones
    grpList = ['GOLD_ID', 'BROAD_SCALE_LABEL', 'LOCAL_SCALE_LABEL', 'MEDIUM_LABEL','ENV_BROAD_SCALE','ENV_LOCAL_SCALE',
    'ENV_MEDIUM', 'TYPE', 'MATCHED TERM', 'PREFERRED FORM', 'CURIE_SYNONYM_REMOVED', 'CURIE_SYNONYM_REMOVED']

    collapsed_io  = input_output_join.groupby(grpList).any()
    collapsed_io.to_csv(NLP_OUTPUT_DIRECTORY+'inputOutputComparison.tsv', sep='\t')
    # IMporting above file: Why? => To flatten the grouped DF in to a standard one.
    new_df = pd.read_csv(NLP_OUTPUT_DIRECTORY+'inputOutputComparison.tsv', sep='\t', low_memory=False)

    # Grouping
    consolidated_df = new_df.groupby(['GOLD_ID'])\
                        .agg({
                                'BROAD_SCALE_LABEL': lambda a: ','.join(a),
                                'LOCAL_SCALE_LABEL': lambda b: ','.join(b),
                                'MEDIUM_LABEL': lambda c: ','.join(c),
                                'ENV_BROAD_SCALE': lambda d: ','.join(d),
                                'ENV_LOCAL_SCALE': lambda e: ','.join(e),
                                'ENV_MEDIUM': lambda f: ','.join(f),
                                'TYPE': lambda g: ','.join(g),
                                'MATCHED TERM': lambda h: ','.join(h),
                                'PREFERRED FORM': lambda i: ','.join(i),
                                'CURIE_SYNONYM_REMOVED': lambda j: ','.join(j),
                                'env_broad_matched': lambda k: any(k == True),
                                'env_local_matched': lambda l: any(l == True),
                                'env_medium_matched': lambda m: any(m == True),
                                'false_positives': lambda n: any(n == False)
                            })
    consolidated_df.to_csv(NLP_OUTPUT_DIRECTORY+'AllGroupedById.tsv', sep='\t')

    all_df = pd.read_csv(NLP_OUTPUT_DIRECTORY+'AllGroupedById.tsv', sep='\t', low_memory=False)
    all_with_text_df = all_df.merge(nlp_input, left_on='GOLD_ID', right_on='id', how='inner')
    all_with_text_df.to_csv(NLP_OUTPUT_DIRECTORY+'AllWithText.tsv', sep='\t', index=None)



def start(input=os.path.join(INPUT_DIRECTORY,INPUT_FILE)):
    '''
    Starts the NER process
    '''
    df = pd.read_csv(input, low_memory=False, sep='\t')


    # Column concatenation for NLP

    df['id'] = df['GOLD_ID']
    df['text'] = df['BIOSAMPLE_NAME'] + '. ' + df['DESCRIPTION'] + '. ' + df['HABITAT'] +'. '+df['SAMPLE_COLLECTION_SITE']

    # Prepare NLP input for runNER
    nlp_df = df[['id', 'text']]
    nlp_ncbi_input = os.path.join(NLP_INPUT_DIRECTORY, NLP_INPUT_FILE)

    nlp_df.to_csv(nlp_ncbi_input, sep='\t', index=False)

    # NER using OGER (via runNER)
    runner.run_oger(settings='settings.ini',workers=5)

    #Postprocess

    post_ner(os.path.join(NLP_OUTPUT_DIRECTORY, 'nlpInput.tsv'))
