insert
	into
	tidy_legal_package_combo
select
	replace(replace(lower(EnvPackage),
	'-',
	' '),
	'/',
	' ') as tidy_legal_package_combo
from
	package_dictionary
where
	EnvPackage is not null
	and EnvPackage != ''
union
select
	replace(replace(lower(EnvPackageDisplay),
	'-',
	' '),
	'/',
	' ')
from
	package_dictionary
where
	EnvPackageDisplay is not null
	and EnvPackageDisplay != ''

