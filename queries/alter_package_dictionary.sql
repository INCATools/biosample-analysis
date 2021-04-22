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

CREATE UNIQUE INDEX if not exists package_name ON
package_dictionary(Name);

CREATE INDEX if not exists package_dictionary_combo ON
package_dictionary(tidy_EnvPackage,
tidy_EnvPackageDisplay,
tidy_checklist);
