-- Business question: Which genres have the highest average IMDb score?
-- Why it matters: Points to genres worth investing more content budget in.
--
-- Noise filters:
--   - imdb_votes >= 1000 per title, so obscure/low-visibility titles with a
--     handful of votes don't skew a genre's average.
--   - genre must have >= 20 qualifying titles, so a genre with 2 lucky
--     high-scorers doesn't beat genres with a large, consistent catalog.

WITH filtered AS (
    SELECT
        t.id,
        t.imdb_score,
        g.genre
    FROM titles_cleaned t
    JOIN titles_genres g ON g.id = t.id
    WHERE t.imdb_score IS NOT NULL
      AND t.imdb_votes >= 1000
)
SELECT
    genre,
    COUNT(*) AS title_count,
    ROUND(AVG(imdb_score), 2) AS avg_imdb_score
FROM filtered
GROUP BY genre
HAVING COUNT(*) >= 20
ORDER BY avg_imdb_score DESC
LIMIT 10;
