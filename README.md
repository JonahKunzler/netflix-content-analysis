# Netflix Content Strategy & Performance Analysis

An end-to-end analysis of Netflix's catalog (titles + credits) to explore content trends,
ratings, genres, countries, and cast/crew performance — using pandas, SQL, and a BI dashboard.

**Status:** Phases 0–1 (setup, cleaning) complete. SQL analysis, deep-dive, and dashboard phases in progress.

## Data Source

- `data/raw/titles.csv` — 5,850 titles (3,744 movies, 2,106 shows): genre, country, runtime, ratings, etc.
- `data/raw/credits.csv` — 77,801 cast/crew credit rows linked to titles via `id`.
- Snapshot date: July 2022. Coverage: primarily US/English-language catalog — not global, not current.

## Data Cleaning (Phase 1)

Full step-by-step reasoning is in [`notebooks/cleaning.ipynb`](notebooks/cleaning.ipynb). Summary
of the non-obvious decisions:

| Issue | Decision | Why |
|---|---|---|
| `seasons` null for all 3,744 movies | Left as `NaN`, not filled with 0 | Not applicable to movies, not missing — 0 would be a false claim |
| `age_certification` null for 2,619 titles (45%) | Filled with `'Not Rated'` | Keeps them visible in group-bys instead of pandas silently dropping NaN keys |
| `imdb_score`/`tmdb_score` null (482 / 311 titles; 88 missing both) | Kept in main table, added `has_any_rating` flag | Only 88 titles lack both scores — dropping 45%+ of columns' worth of rows isn't justified; rating questions filter per-score instead |
| `runtime == 0` (14 titles) | Kept raw value, added `runtime_is_missing` flag | 0 minutes isn't a real runtime; flagged rather than dropped so runtime-correlation analysis can exclude them |
| `genres` / `production_countries` (stringified lists) | Exploded into `titles_genres` / `titles_countries` long-format tables | Needed for per-genre/per-country aggregation; empty-list titles (59 / 229) excluded only from the exploded tables, not the main one |
| `id` dedupe check | Verified 0 duplicates | Integrity check, not a fix |
| `credits` duplicate `(id, person_id, role)` groups (173 rows) | Kept as-is | Legitimate double-credits (different character names), not data errors |

Cleaned outputs live in `data/cleaned/` and are loaded into `netflix.db` as `titles_cleaned`,
`titles_genres`, `titles_countries`, and `credits_cleaned` (raw `titles`/`credits` tables remain
for auditing).

## Project Structure

```
netflix-content-analysis/
├── data/raw/           # titles.csv, credits.csv (original, untouched)
├── data/cleaned/        # cleaned/exploded CSVs produced by notebooks
├── sql/                 # analysis queries (.sql)
├── notebooks/           # exploration.ipynb, cleaning.ipynb
├── dashboard/           # Tableau/Power BI file or link
├── netflix.db            # SQLite database loaded from the raw CSVs
├── requirements.txt
└── README.md
```

## Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

The SQLite database (`netflix.db`) is built from the raw CSVs via `load_to_sqlite.py`.

## Roadmap

- [x] Phase 0 — Repo setup, raw data loaded into SQLite
- [x] Phase 1 — Data cleaning (genre/country explode, null handling, dedupe, decade column)
- [ ] Phase 2 — SQL analysis (8–10 queries)
- [ ] Phase 3 — Pandas deep-dive (stats tests, time series, actor network)
- [ ] Phase 4 — Dashboard (Tableau/Power BI)
- [ ] Phase 5 — Write-up (findings, methodology, caveats)

## Caveats

- Data reflects Netflix's catalog as of **July 2022** — it does not include anything added since.
- No viewership data is included; ratings are IMDb/TMDb scores, not Netflix engagement metrics.
