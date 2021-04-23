.mode tabs
select
	SUBSTR(package,
	1,
	INSTR(package,
	'.')-1) as checklist,
	trim(replace(replace(replace(replace(replace(replace(lower(replace(env_package, 'MIGS/MIMS/MIMARKS.', '')), '-', ' '), '/', ' '), '|', ' '), '_', ' '), ',', ' '), 'environment', '')) as strict_package,
	count(1) as cp_count
from
	biosample
group by
	checklist,
	strict_package
order by
	count(1) desc
