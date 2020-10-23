# Steps to set-up and run the NLP pipeline
### 1. Get the ontology JSON file form OBOFoundry (e.g. Envo)
  `wget http://purl.obolibrary.org/obo/envo.json`

### 2. Install KGX
  `pip install git+git://github.com/biolink/kgx`

### 3. Follow Instruction from [the runNER repo](https://github.com/deepakunni3/runner)
  - [Ontology to KGX TSV](https://github.com/deepakunni3/runner#ontology-to-kgx-tsv)
  - [Preparing term-list](https://github.com/deepakunni3/runner#preparing-term-list)

### 4. Install OGER
  `pip install git+git://github.com/OntoGene/OGER`

### 5. Create the '[settings.ini](settings.ini)' file based on [OGER documentation](https://github.com/OntoGene/OGER/wiki/run#settings-files)

### 6. The Jupyter document ['xmlParsing.ipynb'](../src/notebooks/xmlParsing.ipynb) creates a folder 'allText' and populates it with *.txt files. Each file corresponds to the text going through the entity recognition process with the filename as 'BIOSAMPLE:' id and the text within being the description. This file is too large and hence it is stored in our [google drive](https://drive.google.com/drive/u/0/folders/1eL0v0stoduahjDpoDJIk3z2pJBAU4b2Y)

### 7. Run OGER
  `oger run -s settings.ini -v -j 5`
  - j: number of workers (for parallel threads)
  - v: verbose

### 8. The [output folder](output) should have the result.

### NOTE: The input folder in GitHub has only 1000 text files since the whole dataset is too big for a GitHub upload and the output corresponds to those 1000 text files. The complete datasets can be downloaded from:
- Input: [allText.tgz](https://drive.google.com/file/d/1fDm6dpHL1CPtd8agLk4YIUd7NFvEG-JG/view?usp=sharing)
- Output: [OGER output](https://drive.google.com/file/d/1Lk5VMx5ziWQSpdaoj94JXgOZ3gfrpaJu/view?usp=sharing) (TSV file)
