## Legacy database from 2021-02-23

```sql
select count(1) from biosample b ;
```

timing: 40 seconds

14 300 584 rows (biosamples)

## xquery/basex 2021-07-17

same query

timing: 3 seconds (ids indexed?)

WARNING? 

> SQL Error [1]: [SQLITE_ERROR] SQL error or missing database (too many terms in compound SELECT)

18 290 757 rows

1.28 x the number of biosamples from 2021-02-23

```bash
sqlite3 target/legacy/harmonized_table.db "pragma table_info(biosample);" "" > \
    target/biosample_schema_20210223.txt
sqlite3 target/harmonized_table.db "pragma table_info(biosample);" "" > \
    target/biosample_schema_20210717.txt
cut -d '|' -f 2 target/biosample_schema_20210223.txt | sort > target/biosample_schema_20210223_cols.txt
cut -d '|' -f 2 target/biosample_schema_20210717.txt | sort > target/biosample_schema_20210717_cols.txt
diff target/biosample_schema_20210223_cols.txt target/biosample_schema_20210717_cols.txt | sort > \
    target/biosample_schema_cols_diff.txt
```



## All-NULL column in legacy table

```
< attribute
```



## Change to modelling of Entrez links

```
< entrez_label
< entrez_target
< entrez_value
> entrez_links
```



## Non-attribute metadata not included in legacy table

*Also present in `xref` column. Isolated here for indexing.*

```
> accession
```



## New technical artifacts

*Dropping columns in SQLite is extremely complex and expensive*

```
> dropme1
> dropme2
```



## New attributes

```
> antiviral_treatment_agent
> collection_device
> collection_method
> date_of_prior_antiviral_treat
> date_of_prior_sars_cov_2_infection
> gisaid_accession
> gisaid_virus_name
> host_anatomical_material
> host_anatomical_part
> host_common_name
> host_recent_travel_loc
> host_specimen_voucher
> passage_method
> passage_number
> purpose_of_sampling
> purpose_of_sequencing
> purpose_of_ww_sampling
> sars_cov_2_diag_gene_name_1
> sars_cov_2_diag_gene_name_2
> sars_cov_2_diag_pcr_ct_value_1
> sars_cov_2_diag_pcr_ct_value_2
> sequenced_by
> solar_irradiance
> vaccine_received
> ww_endog_control_1
> ww_endog_control_1_conc
> ww_endog_control_1_protocol
> ww_endog_control_1_units
> ww_flow
> ww_population
> ww_population_source
> ww_processing_protocol
> ww_sample_duration
> ww_sample_matrix
> ww_sample_site
> ww_sample_type
> ww_surv_jurisdiction
> ww_surv_system_sample_id
> ww_surv_target_1
> ww_surv_target_1_conc
> ww_surv_target_1_conc_unit
> ww_surv_target_1_extract
> ww_surv_target_1_extract_unit
> ww_surv_target_1_gene
> ww_surv_target_1_known_present
> ww_surv_target_1_protocol
```