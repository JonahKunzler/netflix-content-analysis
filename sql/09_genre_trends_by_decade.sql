-- Business question: How has genre mix shifted decade over decade?
-- Why it matters: Feeds the Phase 3 time-series breakdown and the dashboard's
-- overview page — shows which genres are rising/falling in the catalog.
--
-- Long format (decade, genre, count) rather than a pivoted table, since it's
-- easier for a BI tool (Tableau/Power BI) to pivot/facet than to unpivot.

SELECT
    t.decade,
    g.genre,
    COUNT(*) AS title_count
FROM titles_cleaned t
JOIN titles_genres g ON g.id = t.id
GROUP BY t.decade, g.genre
ORDER BY t.decade, title_count DESC;
