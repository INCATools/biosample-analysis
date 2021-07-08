#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun  8 13:21:32 2021

@author: MAM
"""

# -*- coding: utf-8 -*-
# Documentation: https://docs.basex.org/wiki/Clients
# (C) BaseX Team 2005-21, BSD License


import pandas as pd
import io
from BaseXClient import BaseXClient

# create session
biosample_session = BaseXClient.Session('localhost', 1984, 'admin', 'admin')


def xquery_to_frame(the_session, the_query, colnames):
    # create query instance
    query = the_session.query(the_query)
    executed = query.execute()
    # close query object
    query.close()
    data = io.StringIO(executed)
    the_frame = pd.read_csv(data, sep="\t", header=None, names=colnames)
    return the_frame


# count the elements of Biosample per biosample
biosample_element_counts_query_string = '''
let $sep := '&#09;'
for $elems in doc(
  'biosample_set'
)/BioSampleSet/BioSample/*
let $currname := name(
  $elems
)
group by $currname
return string-join(
       (
        $currname, count(
      $elems
    )
       ),
       $sep[1]
)
'''

biosample_element_counts_query_frame = xquery_to_frame(
    biosample_session, biosample_element_counts_query_string, ['element', 'count'])


# print(biosample_element_counts_query_frame)

id_attribs_q = '''
let $sep := '&#09;' (: tab :)
for $bs in doc(
  'biosample_set'
)/BioSampleSet/BioSample
let $prim_id := $bs/Ids/Id[@is_primary="1"]
for $id in $bs/Ids/Id
let $idattrib := $id/@*
for $oia in $idattrib
return string-join(
        (
        data(
      $prim_id
    ),
        data(
      $id
    ),
        name(
      $oia
    ),
        string(
      $oia
    )
        ),
        $sep
)
'''

id_attribs_frame = xquery_to_frame(
    biosample_session, id_attribs_q, ['primary', 'id', 'key', 'value', 'extra'])

id_attribs_frame['underflow'] = id_attribs_frame['value'].isnull()
id_attribs_frame['overflow'] = ~ id_attribs_frame['extra'].isnull()
# what about empty strings?

# /Users/MAM/biosample_from_xml/venv/lib/python3.9/site-packages/spyder_kernels/customize/spydercustomize.py:565: DtypeWarning: Columns (4) have mixed types.Specify dtype option on import or set low_memory=False.
#   exec_code(file_code, filename, ns_globals, ns_locals,

id_attribs_frame['underflow'].value_counts(dropna=False)
# specifically check for NaNs too
# doesn't make any difference here
# False    72784463
# True            3

id_attribs_frame['overflow'].value_counts(dropna=False)
# False    72783719
# True          747

pd.set_option('display.max_columns', None)
# print(id_attribs_frame)

primary_ids = id_attribs_frame['primary'].unique()
# print(len(primary_ids))

#---

attrib_attribs_q = '''
let $sep := '&#09;' (: tab :)
for $bs in doc(
  'biosample_set'
)/BioSampleSet/BioSample
let $prim_id := $bs/Ids/Id[@is_primary="1"]
for $attrib in $bs/Attributes/Attribute
let $attrib_attrib := $attrib/@*
for $oia in $attrib_attrib
return string-join(
        (
        data(
      $prim_id
    ), 
        name(
      $oia
    ), 
        string(
      $oia
    ),
              data(
        $attrib
      )
  ), 
        $sep
)
'''

attrib_attribs_frame = xquery_to_frame(
    biosample_session, attrib_attribs_q, ['primary', 'key', 'value', 'data'])



# if biosample_session:
#     biosample_session.close()

# names = list('abcdef'))
