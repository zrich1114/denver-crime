/* WEATHER-CRIME CORRELATIONS */
select offense_category_id from crimes;
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
	ROUND((CAST(auto_theft.days AS DECIMAL) / CAST(total.days AS DECIMAL)), 3) auto_theft_rate
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
		ON total.icon = auto_theft.icon
	ORDER BY auto_theft_rate DESC;

/*
	Do aggrevated assaults occur more frequently on days with extreme temperatures?
*/

SELECT temp_categories.category, COUNT(agg_assaults.*) assault_count
	FROM (
		SELECT w.temp temperature
		FROM weather w INNER JOIN crimes cr
			ON w.datetime::Date = cr.first_occurrence_date::Date
		WHERE cr.offense_category_id = 'aggravated-assault'
	) agg_assaults INNER JOIN (
		SELECT 'COLD DAYS' category, -100 low_threshold, 31.999 high_threshold
		UNION ALL
		SELECT 'MILD DAYS' category, 32.0 low_threshold, 79.999 high_threshold
		UNION ALL
		SELECT 'HOT DAYS' category, 80.0 low_threshold, 200 high_threshold 
	) temp_categories
		ON agg_assaults.temperature BETWEEN temp_categories.low_threshold AND temp_categories.high_threshold
	GROUP BY temp_categories.category;

SELECT w.temp temperature, cr.offense_category_id, w.datetime::Date
	FROM weather w INNER JOIN crimes cr
		ON w.datetime::Date = cr.first_occurrence_date::Date
	WHERE cr.offense_category_id = 'aggravated-assault'
		AND w.temp NOT BETWEEN -100 and 200
	ORDER BY temperature ASC;

SELECT COUNT(*) from crimes where offense_category_id = 'aggravated-assault';