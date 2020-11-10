# Steps to set-up and run the NLP pipeline
### 1. Get the ontology JSON file form OBOFoundry (e.g. Envo)
  `wget http://purl.obolibrary.org/obo/envo.json`

### 2. Install KGX
  `pip install git+git://github.com/biolink/kgx`

### 3. Follow Instruction from [the runNER repo](https://github.com/deepakunni3/runner)
  - [Ontology conversion from JSON to TSV via KGX](https://github.com/deepakunni3/runner#ontology-to-kgx-tsv)
    - In case of the unavailability of JSON format, we can convert an OWL to JSON via [ROBOT](http://robot.obolibrary.org/).</br>
      `robot convert --input input/ncbitaxon.owl --output input/ncbitaxon.json -f json`
    - ROBOT may throw errors during conversion which are addressed [here](http://robot.obolibrary.org/errors.html).
    - If JAVA options need to be declared, [here](https://docs.oracle.com/html/E23737_01/configuring_jvm.htm) is a list. </br>
    `export ROBOT_JAVA_ARGS = <java_options> && robot convert ...` </br>
    For e.g. while converting NCBITaxon.owl to a JSON file, there were 'java heap out of space' and 'garbage collection' errors. The following worked: </br>
    `export ROBOT_JAVA_ARGS="-Xmx8g -XX:+UseConcMarkSweepGC" && robot convert --input input/ncbitaxon.owl --output input/ncbitaxon.json -f json`
    - Rather than running `export ROBOT_JAVA_ARGS="-Xmx8g -XX:+UseConcMarkSweepGC"` repeatedly, we could declare this in ~/.bash_profile directly and take care of it once and for all.
  - [Preparing term-list](https://github.com/deepakunni3/runner#preparing-term-list)
  

### 4. Install OGER
  `pip install git+git://github.com/OntoGene/OGER`

### 5. Create the '[settings.ini](settings.ini)' file based on [OGER documentation](https://github.com/OntoGene/OGER/wiki/run#settings-files)

### 6. The Jupyter document '[xmlParsing.ipynb](../src/notebooks/xmlParsing.ipynb)' creates a folder 'allText' and populates it with *.txt files. Each file corresponds to the text going through the entity recognition process with the filename as 'BIOSAMPLE:' id and the text within being the description. This file is too large and hence it is stored in our [google drive](https://drive.google.com/drive/u/0/folders/1eL0v0stoduahjDpoDJIk3z2pJBAU4b2Y)

### 7. Run OGER
  `oger run -s settings.ini -v -j 5`
  - j: number of workers (for parallel threads)
  - v: verbose

### 8. The [output folder](output) should have the result.

### NOTE: The input folder in GitHub has only 1000 text files since the whole dataset is too big for a GitHub upload and the output corresponds to those 1000 text files. The complete datasets can be downloaded from:
- Input: [allText.tgz](https://drive.google.com/file/d/1fDm6dpHL1CPtd8agLk4YIUd7NFvEG-JG/view?usp=sharing)
- Output: [OGER output](https://drive.google.com/file/d/1Lk5VMx5ziWQSpdaoj94JXgOZ3gfrpaJu/view?usp=sharing) (TSV file)
  - Column Names (as per [OGER code](https://github.com/OntoGene/OGER/blob/master/oger/doc/tsv.py)
    - 'DOCUMENT ID',
    - 'TYPE',
    - 'START POSITION',
    - 'END POSITION',
    - 'MATCHED TERM',
    - 'PREFERRED FORM',
    - 'ENTITY ID',
    - 'ZONE',
    - 'SENTENCE ID',
    - 'ORIGIN',
    - 'UMLS CUI'
