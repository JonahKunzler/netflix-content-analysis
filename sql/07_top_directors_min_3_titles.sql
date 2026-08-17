-- Business question: Who is the highest-rated director with a substantial
-- body of work on the platform (3+ titles)?
-- Why it matters: A one-hit-wonder director isn't as safe a bet for a new
-- deal as someone who's consistently well-rated across multiple titles.

WITH director_stats AS (
    SELECT
        c.person_id,
        c.name,
        COUNT(DISTINCT c.id) AS title_count,
        ROUND(AVG(t.imdb_score), 2) AS avg_imdb_score
    FROM credits_cleaned c
    JOIN titles_cleaned t ON t.id = c.id
    WHERE c.role = 'DIRECTOR'
      AND t.imdb_score IS NOT NULL
    GROUP BY c.person_id
)
SELECT name, title_count, avg_imdb_score
FROM director_stats
WHERE title_count >= 3
ORDER BY avg_imdb_score DESC
LIMIT 10;
