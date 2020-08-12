# Biosample analysis

Repo for analysis of biosamples in INSDC

Questions to explore

 - which attributes/properties are used
 - are these conformant to standards?
    - E.g. are MIxS fields used
    - Does the range constraint aapply?
 - Can we mine ontology terms, e.g. ENVO from text descriptions
 - can we auto-populate metadata fields

# Workflow

See Makefile for details

# Related

https://github.com/cmungall/metadata_converter

# Example bad data

## Depth

MIxS specifies this should be `{number} {unit}`

Some example values that do not conform:

 - N40.1164_W88.2543
 - 25 santimeters
 - 0 – 20 cm
 - 3.149
 - 30-60cm replicate6
 - 1800, 1800
 - 30ft
 - 5m, 32m, 70m, 110m, 200m, 320m, 1000m
 - Surface soil from deep water
 - 0 m water depth
 - Metamorph4 (19dpf) biological replicate 3

## pH

 - pH 7.9
 - 6.0-9.5
 - 8,156
 - NA1
 - 2.75 (orig)
 - 5.11±0.10
 - Missing: Not reported
 - Not collected
 - 7.0-7.5 um
 - Moderately alkaline

## ammonium

Should be {float} {unit}

 - 0.71 micro molar
 - 14.941
 - -0.024
 - 1.9 g NH4-N L-1
 - Below the deteciton limit (2 microM)
 - 3.09µg/L

Units vary from 'micro molar' through uM through mg/L

## geo_loc_name

MIxS:

_The geographical origin of the sample as defined by the country or sea name followed by specific region name. Country or sea names should be chosen from the INSDC country list (http://insdc.org/country.html), or the GAZ ontology (v 1.512) (http://purl.bioontology.org/ontology/GAZ)_

` {term};{term};{text}`

 - USA: WA
 - USA:MO
 - USA: Boston, MA
 - USA:CA:Davis
 - United Kingdom: Midlands and East of England
 - Malawi: GAZ
 
 
