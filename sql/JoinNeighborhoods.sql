select * from crimes limit 10;

select cr.offense_category_id,
	cr.victim_count,
	cr.first_occurrence_date occurrence_date, 
	cr.neighborhood,
	cs.sum_population_2010 population,
	w.temp temperature, 
	w.conditions conditions
from crimes as cr
	inner join weather as w
		on w.datetime::Date = cr.first_occurrence_date::Date
	inner join census as cs
		on cr.neighborhood = cs.name;

select neighborhood, sum(victim_count) victims
	from crimes
	group by neighborhood
	having neighborhood is not null
	order by victims desc;