/* WEATHER-CRIME CORRELATIONS */
SELECT *
	FROM weather w
		INNER JOIN crimes cr
			ON w.datetime::Date = cr.first_occurrence_date::Date
	LIMIT 10;

/*
	Are auto thefts more likely to occur on snowy days?
*/
SELECT total.icon conditions, 
	total.days total_days, 
	auto_theft.days auto_theft_count, 
	(auto_theft.days / total.days) auto_theft_rate
	FROM (
		SELECT w.icon, COUNT(*) days
			FROM weather w
				INNER JOIN crimes cr
					ON w.datetime::Date = cr.first_occurrence_date::Date
			GROUP BY w.icon
	) total INNER JOIN (
		SELECT w.icon, COUNT(*) days
			FROM weather w
				INNER JOIN crimes cr
					ON w.datetime::Date = cr.first_occurrence_date::Date
			WHERE cr.offense_category_id = 'auto-theft'
			GROUP BY w.icon
	) auto_theft
		ON total.icon = auto_theft.icon;

/*
	Do aggrevated assaults occur more frequently on days with extreme temperatures?
*/