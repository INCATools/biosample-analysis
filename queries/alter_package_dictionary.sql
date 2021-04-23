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
