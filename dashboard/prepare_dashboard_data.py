"""
Phase 4: build dashboard-ready CSV extracts from netflix.db.

Tableau Public's free tier works off flat files, not a live SQLite connection,
so this produces a small set of clean, denormalized CSVs — one per dashboard
concern — into dashboard/data/. See dashboard/DASHBOARD_GUIDE.md for how each
file maps to a dashboard page.
"""

import sqlite3
from pathlib import Path

import pandas as pd

DB_PATH = Path(__file__).parent.parent / "netflix.db"
OUT_DIR = Path(__file__).parent / "data"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def main():
    conn = sqlite3.connect(DB_PATH)

    titles = pd.read_sql("SELECT * FROM titles_cleaned", conn)
    titles_genres = pd.read_sql("SELECT * FROM titles_genres", conn)
    titles_countries = pd.read_sql("SELECT * FROM titles_countries", conn)
    credits = pd.read_sql("SELECT * FROM credits_cleaned", conn)
    conn.close()

    # --- titles.csv: one row per title, with a "primary" genre/country for
    # simple single-value filters/colors, plus counts for context. The full
    # many-to-many relationship still lives in titles_genres.csv /
    # titles_countries.csv for filters that should reflect every genre/country
    # a title has, not just its first one.
    primary_genre = (
        titles_genres.groupby("id")["genre"].first().rename("primary_genre")
    )
    genre_count = titles_genres.groupby("id").size().rename("genre_count")
    primary_country = (
        titles_countries.groupby("id")["country"].first().rename("primary_country")
    )
    country_count = titles_countries.groupby("id").size().rename("country_count")

    dashboard_titles = (
        titles[
            [
                "id",
                "title",
                "type",
                "release_year",
                "decade",
                "age_certification",
                "runtime",
                "runtime_is_missing",
                "seasons",
                "imdb_score",
                "imdb_votes",
                "tmdb_score",
                "tmdb_popularity",
                "has_any_rating",
            ]
        ]
        .join(primary_genre, on="id")
        .join(genre_count, on="id")
        .join(primary_country, on="id")
        .join(country_count, on="id")
    )
    dashboard_titles["genre_count"] = dashboard_titles["genre_count"].fillna(0).astype(int)
    dashboard_titles["country_count"] = dashboard_titles["country_count"].fillna(0).astype(int)
    dashboard_titles.to_csv(OUT_DIR / "titles.csv", index=False)

    # --- titles_genres.csv / titles_countries.csv: pass through unchanged,
    # these are the many-to-many link tables Tableau relates to titles.csv on `id`.
    titles_genres.to_csv(OUT_DIR / "titles_genres.csv", index=False)
    titles_countries.to_csv(OUT_DIR / "titles_countries.csv", index=False)

    # --- people_stats.csv: per-person, per-role aggregates (not pre-limited to
    # a top N — Tableau's own Top N filter/parameter handles that live, so the
    # dashboard viewer can adjust it interactively instead of it being baked in).
    person_titles = credits.merge(
        titles[["id", "imdb_score", "tmdb_score"]], on="id", how="left"
    )
    people_stats = (
        person_titles.groupby(["person_id", "name", "role"])
        .agg(
            title_count=("id", "nunique"),
            avg_imdb_score=("imdb_score", "mean"),
            avg_tmdb_score=("tmdb_score", "mean"),
        )
        .round(2)
        .reset_index()
    )
    people_stats.to_csv(OUT_DIR / "people_stats.csv", index=False)

    for name, df in {
        "titles": dashboard_titles,
        "titles_genres": titles_genres,
        "titles_countries": titles_countries,
        "people_stats": people_stats,
    }.items():
        print(f"{name}.csv: {df.shape}")


if __name__ == "__main__":
    main()
