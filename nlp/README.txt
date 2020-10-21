Steps to set-up the NLP pipeline
1. Get the ontology JSON file form OBOFoundry (e.g. Envo)
  a. wget http://purl.obolibrary.org/obo/envo.json

2. Install KGX
  a. pip install git+git://github.com/biolink/kgx

3. Follow Instruction from https://github.com/deepakunni3/runner
  a. Ontology to KGX TSV - https://github.com/deepakunni3/runner#ontology-to-kgx-tsv
  b. Preparing term-list - https://github.com/deepakunni3/runner#preparing-term-list

4. Install OGER
  a. pip install git+git://github.com/OntoGene/OGER

5. Create the 'settings.ini' file based on OGER documentation
  a. https://github.com/OntoGene/OGER/wiki/run#settings-files

6. The Jupyter document 'xmlParsing.ipynb' creates a folder 'allText'
  and populates it with txt files. Each file corresponds to the text going
  through the entity recognition process with the filename = 'BIOSAMPLE:' id
  and the text within being the description.

7. Run OGER
  a. oger run -s settings.ini -v -j 5
    i. j: number of workers (for parallel threads)
    ii. v: verbose

8. The ouput folder should have the result.
