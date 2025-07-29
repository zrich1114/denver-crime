/* CENSUS-ADJUSTED INSIGHTS */
SELECT * FROM census LIMIT 10;
SELECT * FROM crimes LIMIT 100;

/*
	Which neighborhoods have the highest crime rates per capita?
*/
SELECT cr.neighborhood, 
	cs.sum_population_2010, 
	COUNT(*) assault_counts_2025, 
	ROUND((CAST(COUNT(*) AS Decimal) / CAST(cs.sum_population_2010 AS Decimal) * 1000), 1) assaults_per_capita_2025
	FROM census cs INNER JOIN crimes cr
		ON cs.name = cr.neighborhood
	WHERE cr.offense_category_id = 'aggravated-assault'
		AND EXTRACT(YEAR FROM cr.first_occurrence_date::Date) = '2025'
	GROUP BY cr.neighborhood, cs.sum_population_2010
	ORDER BY assaults_per_capita_2025 DESC;
/*
	Is there a correlation between home ownership and larceny rates?
*/
SELECT cr.neighborhood,
	cs.sum_population_2010 population_2010,
	cs.sum_owned_w_mortg_loan mortgage_owned_2010, 
	cs.sum_owned_free_clear free_clear_owned_2010, 
	(cs.sum_owned_w_mortg_loan + cs.sum_owned_free_clear) total_owned_2010, 
	ROUND((CAST((cs.sum_owned_w_mortg_loan + cs.sum_owned_free_clear) AS Decimal) / CAST(cs.sum_population_2010 AS Decimal)), 2) rate_owned_2010,
	COUNT(cr.*) offense_count_2025,
	ROUND((CAST(COUNT(cr.*) AS Decimal) / CAST(cs.sum_population_2010 AS Decimal)), 2) offense_rate_2025
		FROM census cs INNER JOIN crimes cr
			ON cs.name = cr.neighborhood
		WHERE cr.offense_category_id = 'larceny'
			AND EXTRACT(YEAR FROM cr.first_occurrence_date::Date) = '2025'
	GROUP BY cr.neighborhood, population_2010, mortgage_owned_2010, free_clear_owned_2010, total_owned_2010, rate_owned_2010
	ORDER BY offense_rate_2025 DESC, rate_owned_2010 DESC;

/*
	Do neighborhoods with different age profiles have different crime rates?
*/