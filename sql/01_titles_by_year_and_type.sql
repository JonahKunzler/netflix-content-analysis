-- Business question: How has the mix of movies vs. TV shows changed over time?
-- Why it matters: A shifting movie/show ratio signals a content-strategy shift
-- (e.g. investing more in episodic content to drive retention).
--
-- Caveat: this dataset has no "date added to Netflix" field, only release_year
-- (production year). This is a proxy for content-strategy trend, not literal
-- catalog-addition trend.

SELECT
    release_year,
    type,
    COUNT(*) AS title_count
FROM titles_cleaned
GROUP BY release_year, type
ORDER BY release_year, type;
