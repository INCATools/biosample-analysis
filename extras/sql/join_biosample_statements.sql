select
	distinct env_broad_scale, st.*
from
	biosample b
join statements st on
	st.subject = b.env_broad_scale
	where st.predicate  = 'rdfs:label'