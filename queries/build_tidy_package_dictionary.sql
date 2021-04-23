-- drop table tidy_package_dictionary

CREATE TABLE IF NOT EXISTS tidy_package_dictionary (Name,
EnvPackage,
EnvPackageDisplay,
tidy_checklist,
tidy_EnvPackage,
tidy_EnvPackageDisplay) ;

DELETE
FROM
	tidy_package_dictionary;

---

insert
	into
	tidy_package_dictionary ( Name,
	EnvPackage,
	EnvPackageDisplay)
select
	Name,
	EnvPackage,
	EnvPackageDisplay
from
	package_dictionary;

---

update
	tidy_package_dictionary
set
	tidy_EnvPackage = replace(replace(lower(EnvPackage),
	'-',
	' '),
	'/',
	' ') ,
	tidy_EnvPackageDisplay = replace(replace(lower(EnvPackageDisplay),
	'-',
	' '),
	'/',
	' '),
	tidy_checklist = SUBSTR(Name,
	1,
	INSTR(Name,
	'.')-1);

ALTER TABLE package_dictionary ADD COLUMN tidy_EnvPackage text ;

ALTER TABLE package_dictionary ADD COLUMN tidy_EnvPackageDisplay text ;

ALTER TABLE package_dictionary ADD COLUMN tidy_checklist text ;

update
	package_dictionary
set
	tidy_EnvPackage = replace(replace(lower(EnvPackage),
	'-',
	' '),
	'/',
	' ') ,
	tidy_EnvPackageDisplay = replace(replace(lower(EnvPackageDisplay),
	'-',
	' '),
	'/',
	' '),
	tidy_checklist = SUBSTR(Name,
	1,
	INSTR(Name,
	'.')-1);
