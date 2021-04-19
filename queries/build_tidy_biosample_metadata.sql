.mode tabs
-- drop table tidy_biosample_metadata
 CREATE TABLE IF NOT EXISTS tidy_biosample_metadata (id,
package,
env_package,
checklist_extract,
env_package_extract,
checklist_package) ;

DELETE
FROM
	tidy_biosample_metadata;
---
 insert
	into
	tidy_biosample_metadata ( id,
	package,
	env_package,
	checklist_extract,
	env_package_extract,
	checklist_package)
select
	id,
	package,
	env_package,
	'',
	'',
	''
from
	biosample ;
---
 update
	tidy_biosample_metadata
set
	checklist_extract = SUBSTR(package,
	1,
	INSTR(package,
	'.')-1),
	env_package_extract = replace(replace(lower(env_package),
	'-',
	' '),
	'/',
	' ') ;
---
 update
	tidy_biosample_metadata
set
	checklist_extract = ''
where
	checklist_extract is null ;
---
 update
	tidy_biosample_metadata
set
	env_package_extract = ''
where
	env_package_extract is null ;
---
 UPDATE
	tidy_biosample_metadata
SET
	checklist_package = (
	SELECT
		Name
	FROM
		tidy_package_dictionary
	WHERE
		checklist_extract = tidy_package_dictionary.tidy_checklist
		and env_package_extract = tidy_package_dictionary.tidy_EnvPackage)
where
	EXISTS (
	SELECT
		EnvPackageDisplay
	FROM
		tidy_package_dictionary
	WHERE
		checklist_extract = tidy_package_dictionary.tidy_checklist
		and env_package_extract = tidy_package_dictionary.tidy_EnvPackage);

UPDATE
	tidy_biosample_metadata
SET
	checklist_package = (
	SELECT
		Name
	FROM
		tidy_package_dictionary
	WHERE
		checklist_extract = tidy_package_dictionary.tidy_checklist
		and env_package_extract = tidy_package_dictionary.tidy_EnvPackageDisplay)
where
	EXISTS (
	SELECT
		EnvPackageDisplay
	FROM
		tidy_package_dictionary
	WHERE
		checklist_extract = tidy_package_dictionary.tidy_checklist
		and env_package_extract = tidy_package_dictionary.tidy_EnvPackageDisplay)
	AND checklist_package = '';
---
 select
	checklist_package,
	(count(1)) as checklist_package_count
from
	tidy_biosample_metadata
group by
	checklist_package
order by
	(count(1)) DESC
