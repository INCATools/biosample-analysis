select
	scoping_value ,
	biosample_col_to_map,
	consensus_id ,
	consensus_lab,
	count(1) as count
from
	repaired_long rl
group by
	scoping_value ,
	biosample_col_to_map,
	consensus_id ,
	consensus_lab
order by
	scoping_value ,
	biosample_col_to_map,
	consensus_lab

