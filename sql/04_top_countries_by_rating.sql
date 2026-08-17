-- Business question: Which production countries produce the highest-rated
-- content?
-- Why it matters: Guides where to expand local-content investment/co-productions.
--
-- Noise filter: country must have >= 20 rated titles, so a country with 1-2
-- titles that happen to score well doesn't outrank countries with a deep,
-- consistently-rated catalog (e.g. US, IN, GB).

WITH filtered AS (
    SELECT
        t.id,
        t.imdb_score,
        c.country
    FROM titles_cleaned t
    JOIN titles_countries c ON c.id = t.id
    WHERE t.imdb_score IS NOT NULL
)
SELECT
    country,
    COUNT(*) AS title_count,
    ROUND(AVG(imdb_score), 2) AS avg_imdb_score
FROM filtered
GROUP BY country
HAVING COUNT(*) >= 20
ORDER BY avg_imdb_score DESC
LIMIT 10;
