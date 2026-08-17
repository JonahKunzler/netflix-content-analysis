-- Business question: Do movies or TV shows rate better on average?
-- Why it matters: Informs the movie-vs-show investment mix. This query is
-- descriptive only — Phase 3 runs a t-test on the same split to check
-- whether the gap is statistically significant or just noise.

SELECT
    type,
    COUNT(*) AS title_count,
    SUM(CASE WHEN imdb_score IS NOT NULL THEN 1 ELSE 0 END) AS rated_title_count,
    ROUND(AVG(imdb_score), 2) AS avg_imdb_score,
    ROUND(AVG(tmdb_score), 2) AS avg_tmdb_score
FROM titles_cleaned
GROUP BY type;
