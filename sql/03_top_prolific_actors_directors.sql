-- Business question: Who are the 10 most prolific actors and the 10 most
-- prolific directors on the platform, and how well-rated is their work?
-- Why it matters: Identifies talent relationships worth deepening (multi-title
-- deals) and whether prolific = reliably well-rated or just high-volume.
--
-- Note: title_count counts distinct titles credited to the person; avg_imdb_score
-- is limited to their titles that have an IMDb score (see cleaning decision on
-- imdb_score nulls).

WITH person_stats AS (
    SELECT
        c.person_id,
        c.name,
        c.role,
        COUNT(DISTINCT c.id) AS title_count,
        ROUND(AVG(t.imdb_score), 2) AS avg_imdb_score
    FROM credits_cleaned c
    JOIN titles_cleaned t ON t.id = c.id
    WHERE t.imdb_score IS NOT NULL
    GROUP BY c.person_id, c.role
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY role ORDER BY title_count DESC) AS rn
    FROM person_stats
)
SELECT role, name, title_count, avg_imdb_score
FROM ranked
WHERE rn <= 10
ORDER BY role, title_count DESC;
