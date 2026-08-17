-- Business question: Does a movie's runtime correlate with its IMDb score?
-- Why it matters: Tests the "longer movies are seen as more prestigious /
-- rated higher" hypothesis, which would inform runtime guidance for
-- commissioned films.
--
-- SQLite has no built-in CORR()/stats aggregate, so this computes the Pearson
-- correlation coefficient by hand from the standard formula:
--   r = (n*sum(xy) - sum(x)*sum(y)) / sqrt((n*sum(x^2) - sum(x)^2) * (n*sum(y^2) - sum(y)^2))
-- Movies with runtime == 0 are excluded (see cleaning decision:
-- runtime_is_missing flags these as not-a-real-duration, not "0 minutes").

WITH movie_data AS (
    SELECT runtime, imdb_score
    FROM titles_cleaned
    WHERE type = 'MOVIE'
      AND imdb_score IS NOT NULL
      AND runtime_is_missing = 0
),
sums AS (
    SELECT
        COUNT(*) AS n,
        SUM(runtime) AS sum_x,
        SUM(imdb_score) AS sum_y,
        SUM(runtime * imdb_score) AS sum_xy,
        SUM(runtime * runtime) AS sum_xx,
        SUM(imdb_score * imdb_score) AS sum_yy
    FROM movie_data
)
SELECT
    n AS n_movies,
    ROUND((n * sum_xy - sum_x * sum_y) / (SQRT(n * sum_xx - sum_x * sum_x) * SQRT(n * sum_yy - sum_y * sum_y)), 4) AS pearson_r
FROM sums;
