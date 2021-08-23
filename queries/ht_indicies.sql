create index biosample_package_name_idx on biosample(package_name);
create index biosample_package_idx on biosample(package);
create index biosample_p_pn_idx on biosample(package, package_name);
create index biosample_env_package_idx on biosample(env_package);
create index biosample_taxonomy_id_idx on biosample(taxonomy_id);
