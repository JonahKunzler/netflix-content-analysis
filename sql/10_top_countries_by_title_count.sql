-- Business question: Which countries produce the most titles on the platform?
-- Why it matters: Overview-page context for query 04 (top countries by
-- rating) — a country can be "top-rated" on a tiny catalog, so this shows
-- catalog depth alongside it. No rating filter here: this is a count-based
-- question, so titles with missing scores are still included (per the
-- Phase 1 cleaning decision on imdb_score/tmdb_score nulls).

SELECT
    country,
    COUNT(*) AS title_count
FROM titles_countries
GROUP BY country
ORDER BY title_count DESC
LIMIT 10;
