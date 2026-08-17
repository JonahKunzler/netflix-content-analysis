# Dashboard Build Guide (Phase 4)

This is a build spec for the actual dashboard, built in Tableau Public (free, shareable) or
Power BI. The GUI build itself has to happen in that tool — this doc + the CSVs in `data/` are
everything needed to build it without re-deriving anything.

## 1. Data files

All in `dashboard/data/`, regenerated any time from `netflix.db` via
`python dashboard/prepare_dashboard_data.py`:

| File | Grain | Use |
|---|---|---|
| `titles.csv` | 1 row per title (5,850) | Main fact table — ratings, runtime, decade, type, `primary_genre`/`primary_country` for simple filters |
| `titles_genres.csv` | 1 row per (title, genre) (15,088) | Many-to-many genre relationship — use this, not `primary_genre`, for any genre filter/breakdown that should count a title under *all* its genres |
| `titles_countries.csv` | 1 row per (title, country) (6,528) | Same, for country |
| `people_stats.csv` | 1 row per (person, role) (55,001) | Actor/director title counts + avg ratings, pre-aggregated |

## 2. Connect & relate

1. Connect to all four CSVs as data sources.
2. Relate `titles_genres` and `titles_countries` to `titles` on `id` (many-to-one from the link
   tables' perspective — a title can have several genres/countries, so keep aggregations that
   use these tables title-count-aware, e.g. `COUNTD(id)` not `COUNT(*)`, to avoid double-counting
   titles that appear in a genre/country more than once elsewhere in a view).
3. `people_stats` doesn't need a relationship to the others — it's used standalone on the People
   page.

## 3. Suggested filters/parameters (apply globally where noted)

- **Year range** (global): slider on `release_year`, default full range.
- **Type** (global): `MOVIE` / `SHOW` toggle.
- **Genre** (Overview + Ratings pages): multi-select on `titles_genres.genre`.
- **Min title count** parameter (Ratings + People pages): integer parameter (default 20 for
  countries/genres, 3 for directors) — lets the viewer tighten/loosen the noise filters from
  Phase 2's SQL instead of them being fixed.

## 4. Page 1 — Overview

- **KPI tiles:** total titles, % movies vs. shows, date range covered.
- **Titles by year, split by type:** line or area chart, `release_year` (x) × `COUNTD(id)` (y),
  colored by `type`. (Source: `titles.csv`; matches `sql/01_titles_by_year_and_type.sql`.)
- **Top genres by title count:** horizontal bar, `titles_genres.genre` × `COUNTD(id)`, top 10.
- **Top countries by title count:** horizontal bar or map, `titles_countries.country` ×
  `COUNTD(id)`, top 10. (Matches `sql/10_top_countries_by_title_count.sql`.)

## 5. Page 2 — Ratings

- **IMDb vs. TMDb comparison:** scatter plot, `imdb_score` (x) vs. `tmdb_score` (y), one point
  per title, colored by `type`; add a diagonal reference line — points far from it are the
  biggest-disagreement titles from `sql/06_imdb_tmdb_score_gap.sql`.
- **Top-rated genres:** bar chart, `titles_genres.genre` × `AVG(imdb_score)`, filtered to
  `imdb_votes >= 1000` and genre title count ≥ the min-title-count parameter (matches
  `sql/02_top_genres_by_rating.sql`).
- **Top-rated countries:** same pattern using `titles_countries.country`, filtered to the
  min-title-count parameter (matches `sql/04_top_countries_by_rating.sql`).
- **Movie vs. show rating:** box plot or bar-with-error-bars, `type` × `imdb_score` — this is the
  chart version of the Phase 3 t-test finding (d=0.66, shows rate meaningfully higher).

## 6. Page 3 — People

- **Top actors by title count:** horizontal bar, `people_stats` filtered to `role = 'ACTOR'`,
  sorted by `title_count` desc, top 10 — with `avg_imdb_score` as a second encoding (color or a
  dual-axis) so volume and quality are both visible at once.
- **Top directors by title count:** same, `role = 'DIRECTOR'`.
- **Highest-rated director (3+ titles):** bar or single-value tile highlighting the top result
  from `sql/07_top_directors_min_3_titles.sql`, with the min-title-count parameter driving the
  "3+" threshold so a viewer can raise it.

## 7. Publish

- **Tableau Public:** File → Save to Tableau Public As… → sign in/create a free account → gives
  a shareable `public.tableau.com/...` link.
- **Power BI:** Publish → Publish to Power BI service → Share → get a link (or export the report
  and note that a viewer needs Power BI Desktop/a work or school account to open it, since Power
  BI's free sharing is more restricted than Tableau Public's).

Once published, drop the link (and ideally a screenshot) into the README's Dashboard section for
Phase 5.
