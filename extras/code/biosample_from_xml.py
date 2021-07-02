#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun  7 17:19:42 2021

@author: MAM
"""

import pandas as pd
import os
import datetime
# import BaseXClient

# 'primary&#09;id&#09;key&#09;value',
# let $sep := '&#09;' (: tab :)
# let $header := "primary id key value"
# for $bs in doc('biosample_set')/BioSampleSet/BioSample
# let $prin_id := $bs/Ids/Id[@is_primary="1"]
# for $id in $bs/Ids/Id
# let $idattrib := $id/@*
# for $oia in $idattrib
# return string-join(
#        (
#         data($prin_id),
#         data($id),
#         name($oia),
#         string($oia)   
#        ),
#        $sep)

starttime = datetime.datetime.now()
print(starttime)

my_path = '/Users/MAM/biosample_from_xml'
bs_id_xq_res_fn = 'bs_id_attribs.tsv'
bs_elems_fn = 'bs_elems.txt'
col_sep = '\t'
bs_id_xq_res_cols = ['Biosample_dyn_uuid','Id_dyn_uuid','key','val']

# should probably use this as a prefix
# or push the previous CWD to be popped at the end of this script
os.chdir(my_path)

bs_id_xq_res = pd.read_csv(bs_id_xq_res_fn, sep=col_sep, header=0)
bs_id_xq_res.columns = bs_id_xq_res_cols
biosample_count = len(pd.unique(bs_id_xq_res['Biosample_dyn_uuid']))
bs_id_attr_counts = bs_id_xq_res['key'].value_counts()
primary_flag = bs_id_xq_res['key'] == 'is_primary'
primary_frame = bs_id_xq_res.loc[primary_flag]
primary_count = len(primary_frame.index)
endtime = datetime.datetime.now()
print(endtime)
durationtime = endtime - starttime
print(durationtime)


# let $sep := '&#09;' (: tab :)
# for $bs in doc('biosample_set')/BioSampleSet/BioSample
# let $elems := $bs/*
# for $current in $elems
# return(name($current))


starttime = datetime.datetime.now()
print(starttime)
bs_elems_res = pd.read_csv(bs_elems_fn, sep=col_sep, header=0)
endtime = datetime.datetime.now()
print(endtime)
durationtime = endtime - starttime
print(durationtime)

elems_count = bs_elems_res.value_counts()