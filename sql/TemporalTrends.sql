/* TEMPORAL TRENDS */
select * from crimes limit 10;

/*
	How do crime rates vary by neighborhood over time?
*/
SELECT EXTRACT(YEAR FROM first_occurrence_date) crime_year, neighborhood, COUNT(*)
	FROM crimes
	WHERE neighborhood IS NOT NULL
	GROUP BY crime_year, neighborhood
	ORDER BY neighborhood;
/*
	Are certain types of crimes more prevelant during particular times of the year?
*/
SELECT EXTRACT(MONTH FROM first_occurrence_date) occurrence_month, offense_category_id offense, COUNT(*) offense_count
	FROM crimes
	GROUP BY occurrence_month, offense_category_id
	ORDER BY offense, offense_count DESC, occurrence_month;
/*
	What's the trend in reporting delay?
*/
SELECT EXTRACT(YEAR FROM first_occurrence_date) reporting_year, EXTRACT (DAY FROM AVG(reported_date - first_occurrence_date)) days_delay
	FROM crimes
	GROUP BY reporting_year
	ORDER BY reporting_year;

/*
	Which neighborhoods have had the sharpest increase in crimes since 2020?
*/
SELECT cr.neighborhood, (
		SELECT COUNT(*)
			FROM crimes
			WHERE neighborhood = cr.neighborhood
				AND EXTRACT(YEAR FROM first_occurrence_date) = '2020'
	) count_2020, (
		SELECT COUNT(*)
			FROM crimes
			WHERE neighborhood = cr.neighborhood
				AND EXTRACT(YEAR FROM first_occurrence_date) = '2025'
	) count_2025
		FROM crimes AS cr
		WHERE cr.neighborhood IS NOT NULL
		GROUP BY cr.neighborhood
		ORDER BY cr.neighborhood;