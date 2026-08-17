-- Business question: Which titles do IMDb and TMDb audiences disagree on most?
-- Why it matters: A large score gap flags titles worth a closer look — e.g.
-- a niche/critical favorite vs. a broad-audience crowd-pleaser, which changes
-- how the title should be marketed/positioned.
--
-- Both scores are on the same ~0-10 scale (verified: imdb_score in [1.5, 9.6],
-- tmdb_score in [0.5, 10.0]), so a direct difference is meaningful without
-- rescaling.

SELECT
    title,
    type,
    imdb_score,
    tmdb_score,
    ROUND(ABS(imdb_score - tmdb_score), 2) AS score_gap
FROM titles_cleaned
WHERE imdb_score IS NOT NULL
  AND tmdb_score IS NOT NULL
ORDER BY score_gap DESC
LIMIT 15;
