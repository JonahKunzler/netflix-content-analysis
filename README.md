# Netflix Content Strategy & Performance Analysis

An end-to-end analysis of Netflix's catalog (titles + credits) to explore content trends,
ratings, genres, countries, and cast/crew performance — using pandas, SQL, and a BI dashboard.

**Status:** Phase 0 (setup) complete. Cleaning, SQL analysis, deep-dive, and dashboard phases in progress.

## Data Source

- `data/raw/titles.csv` — 6,002 titles (movies + shows): genre, country, runtime, ratings, etc.
- `data/raw/credits.csv` — 77,801 cast/crew credit rows linked to titles via `id`.
- Snapshot date: July 2022. Coverage: primarily US/English-language catalog — not global, not current.

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
- [ ] Phase 1 — Data cleaning (genre/country explode, null handling, dedupe, decade column)
- [ ] Phase 2 — SQL analysis (8–10 queries)
- [ ] Phase 3 — Pandas deep-dive (stats tests, time series, actor network)
- [ ] Phase 4 — Dashboard (Tableau/Power BI)
- [ ] Phase 5 — Write-up (findings, methodology, caveats)

## Caveats

- Data reflects Netflix's catalog as of **July 2022** — it does not include anything added since.
- No viewership data is included; ratings are IMDb/TMDb scores, not Netflix engagement metrics.
