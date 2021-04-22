.mode tabs
---
 CREATE UNIQUE INDEX if not exists biosample_metadata_id ON
biosample(id);
---
-- ~4 minutes/240 seconds
-- maybe a unique value temp table should be extracted, 

-- normalized and them merged back in?
 update
	biosample
set
	checklist_extract = SUBSTR(package,
	1,
	INSTR(package,
	'.')-1);
---
 update
	biosample
set
	env_package_extract = replace(replace(lower(replace(env_package, 'MIGS/MIMS/MIMARKS.', '')),
	'-',
	' '),
	'/',
	' ') ;
---
 CREATE INDEX if not exists biosample_metadata_both ON
biosample(env_package_extract,
checklist_extract);
---

-- unnecessary?
 update
	biosample
set
	checklist_extract = ''
where
	checklist_extract is null ;
---
 update
	biosample
set
	env_package_extract = ''
where
	env_package_extract is null ;
---
 UPDATE
	biosample
SET
	checklist_package_combo = '' ;
---
 UPDATE
	biosample
SET
	checklist_package_combo = (
	SELECT
		Name
	FROM
		package_dictionary
	WHERE
		checklist_extract = package_dictionary.tidy_checklist
		and env_package_extract = package_dictionary.tidy_EnvPackage)
where
	EXISTS (
	SELECT
		tidy_EnvPackage
	FROM
		package_dictionary
	WHERE
		checklist_extract = package_dictionary.tidy_checklist
		and env_package_extract = package_dictionary.tidy_EnvPackage)
	AND checklist_package_combo = '' ;
---
 UPDATE
	biosample
SET
	checklist_package_combo = (
	SELECT
		Name
	FROM
		package_dictionary
	WHERE
		checklist_extract = package_dictionary.tidy_checklist
		and env_package_extract = package_dictionary.tidy_EnvPackageDisplay)
where
	EXISTS (
	SELECT
		tidy_EnvPackageDisplay
	FROM
		package_dictionary
	WHERE
		checklist_extract = package_dictionary.tidy_checklist
		and env_package_extract = package_dictionary.tidy_EnvPackageDisplay)
	AND checklist_package_combo = '' ;
---
 CREATE INDEX if not exists biosample_metadata_combo ON
biosample(checklist_package_combo);
---
 SELECT
	checklist_extract ,
	env_package_extract ,
	count(1)
FROM
	biosample
where
	checklist_package_combo = ''
group by
	checklist_extract ,
	env_package_extract
order by
	count(1) desc;
